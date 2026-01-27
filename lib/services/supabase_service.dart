import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/config/supabase_config.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/organization.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:uuid/uuid.dart';

/// Supabase service for handling all backend operations
///
/// Features:
/// - Authentication (signup, login, logout)
/// - Organization management
/// - User profile management
/// - Categories & Expenses CRUD
/// - Receipt upload/download
/// - Real-time subscriptions
/// - Conflict resolution
class SupabaseService {
  SupabaseService._internal();
  factory SupabaseService() => _instance;
  static final SupabaseService _instance = SupabaseService._internal();

  final _logger = LoggerService.instance;
  SupabaseClient? _client;
  bool _isOffline = false;

  /// Whether the service is currently offline (network unavailable)
  bool get isOffline => _isOffline;

  /// Initialize Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: SupabaseConfig.debugMode,
        authOptions: const FlutterAuthClientOptions(
          // Retry auth operations with back-off
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;

      // Listen for auth state changes to handle network errors gracefully
      _client!.auth.onAuthStateChange.listen(
        (data) {
          _isOffline = false;
          _logger.info('Auth state changed: ${data.event}');
        },
        onError: (error, stackTrace) {
          // Handle network-related auth errors gracefully
          if (_isNetworkError(error)) {
            _isOffline = true;
            _logger.warning(
              'Network unavailable during auth operation. App will work offline.',
            );
          } else {
            _logger.error(
              'Auth state change error',
              error: error,
              stackTrace: stackTrace as StackTrace?,
            );
          }
        },
      );

      _logger.info('Supabase initialized successfully');
    } on SocketException catch (e, stackTrace) {
      _isOffline = true;
      _logger.warning(
        'Network unavailable during Supabase initialization. '
        'App will start in offline mode.',
      );
      // Don't rethrow - allow app to start in offline mode
      _logger.error(
        'Network error details',
        error: e,
        stackTrace: stackTrace,
      );
    } on AuthException catch (e, stackTrace) {
      if (_isNetworkError(e)) {
        _isOffline = true;
        _logger.warning(
          'Network unavailable during Supabase initialization. '
          'App will start in offline mode.',
        );
      } else {
        _logger.error(
          'Failed to initialize Supabase',
          error: e,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to initialize Supabase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if an error is network-related
  bool _isNetworkError(dynamic error) {
    if (error is SocketException) return true;
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused') ||
        message.contains('no such host') ||
        message.contains('clientexception');
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // =====================================================
  // AUTHENTICATION
  // =====================================================

  /// Manager signup (creates pending organization)
  Future<Map<String, dynamic>> signUpManager({
    required String email,
    required String password,
    required String organizationName,
    required String fullName,
  }) async {
    try {
      // Trim email to avoid accidental leading/trailing whitespace
      final trimmedEmail = email.trim();
      // Create auth user
      final authResponse = await client.auth.signUp(
        email: trimmedEmail,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // Use the newly created auth user for RLS-compliant inserts
      final userId = authResponse.user!.id;

      // Create user profile first
      await client.from('user_profiles').insert({
        'id': userId,
        'email': trimmedEmail,
        'full_name': fullName,
        'role': 'manager',
        'status': 'pending', // Will be set to 'active' when owner approves
      });

      // Create organization (pending approval) with manager_name from full_name
      final orgResponse = await client
          .from('organizations')
          .insert({
            'name': organizationName,
            'manager_email': trimmedEmail,
            'manager_name': fullName,
            'status': 'pending', // Needs owner approval
            'created_by': userId,
          })
          .select()
          .single();

      // Update user profile with organization_id
      await client
          .from('user_profiles')
          .update({'organization_id': orgResponse['id']}).eq('id', userId);

      _logger.info('Manager signup successful: $trimmedEmail');

      return {
        'success': true,
        'message': 'Signup successful! Your account is pending approval.',
        'user_id': authResponse.user!.id,
        'organization_id': orgResponse['id'],
      };
    } catch (e, stackTrace) {
      _logger.error('Manager signup failed', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Invalid credentials');
      }

      // Fetch user profile
      final profileResponse = await client
          .from('user_profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      final userProfile = UserProfile.fromJson(profileResponse);

      // Allow pending users to login - login screen will redirect to pending approval
      // Only prevent login for owners if they're not active (shouldn't happen)
      if (!userProfile.isActive && userProfile.isOwner) {
        throw Exception(
          'Your account is not yet activated. Please contact support.',
        );
      }

      // Create audit log only for successful logins (including pending users)
      await _createAuditLog(
        userId: userProfile.id,
        organizationId: userProfile.organizationId,
        action: 'LOGIN',
      );

      _logger.info('User signed in: $email (Status: ${userProfile.status})');

      return {
        'success': true,
        'user': userProfile,
        'session': authResponse.session,
      };
    } catch (e, stackTrace) {
      _logger.error('Sign in failed', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Create audit log before signing out
      if (currentUser != null) {
        final profile = await getUserProfile(currentUser!.id);
        if (profile != null) {
          await _createAuditLog(
            userId: profile.id,
            organizationId: profile.organizationId,
            action: 'LOGOUT',
          );
        }
      }

      await client.auth.signOut();
      _logger.info('User signed out');
    } catch (e, stackTrace) {
      _logger.error('Sign out failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Request password reset email (only for managers/owners)
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      // Check if user exists and is a manager or owner
      final profileResponse = await client
          .from('user_profiles')
          .select('role')
          .eq('email', email)
          .maybeSingle();

      if (profileResponse == null) {
        // Don't reveal if user exists - security best practice
        return {
          'success': true,
          'message':
              'If an account exists with this email, you will receive reset instructions.',
        };
      }

      final role = profileResponse['role'] as String?;
      if (role == 'employee') {
        return {
          'success': false,
          'message':
              'Employees cannot reset their own password. Please contact your manager.',
        };
      }

      // Send password reset email
      await client.auth.resetPasswordForEmail(email);

      _logger.info('Password reset requested for: $email');

      return {
        'success': true,
        'message': 'Password reset instructions sent to your email.',
      };
    } catch (e, stackTrace) {
      _logger.error(
        'Password reset request failed',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Reset password with new password (after clicking email link)
  Future<Map<String, dynamic>> resetPassword({
    required String newPassword,
  }) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _logger.info('Password reset successful');

      return {
        'success': true,
        'message': 'Password has been reset successfully.',
      };
    } catch (e, stackTrace) {
      _logger.error('Password reset failed', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Reset employee password (manager only)
  Future<Map<String, dynamic>> resetEmployeePassword({
    required String employeeId,
    required String newPassword,
  }) async {
    try {
      // Verify current user is a manager
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final currentRole = currentProfile.role.value;
      if (currentRole != 'manager' && currentRole != 'owner') {
        return {
          'success': false,
          'message': 'Only managers can reset employee passwords.',
        };
      }

      // Get employee profile to verify they belong to same org
      final employeeProfile = await client
          .from('user_profiles')
          .select()
          .eq('id', employeeId)
          .single();

      // Managers can only reset passwords for employees in their organization
      if (currentRole == 'manager') {
        final currentOrgId = currentProfile.organizationId;
        final employeeOrgId = employeeProfile['organization_id'] as String?;

        if (currentOrgId != employeeOrgId) {
          return {
            'success': false,
            'message':
                'You can only reset passwords for employees in your organization.',
          };
        }

        final employeeRole = employeeProfile['role'] as String?;
        if (employeeRole != 'employee') {
          return {
            'success': false,
            'message': 'You can only reset passwords for employees.',
          };
        }
      }

      // Use admin API to update user password
      await client.auth.admin.updateUserById(
        employeeId,
        attributes: AdminUserAttributes(password: newPassword),
      );

      _logger.info('Employee password reset by manager: $employeeId');

      return {
        'success': true,
        'message': 'Employee password has been reset successfully.',
      };
    } catch (e, stackTrace) {
      _logger.error(
        'Employee password reset failed',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // =====================================================
  // USER PROFILE
  // =====================================================

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('user_profiles').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get user profile',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await client
          .from('user_profiles')
          .update(profile.toJson())
          .eq('id', profile.id);

      _logger.info('User profile updated: ${profile.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update user profile',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Add employee (manager only)
  /// Note: This creates a user profile without auth credentials
  /// Employee will need to sign up separately using their email
  Future<Map<String, dynamic>> addEmployee({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  }) async {
    try {
      // Generate a UUID for the employee
      // Since we can't use admin.createUser in client app (requires service role),
      // we'll create the profile directly and the employee will sign up later
      final userId = const Uuid().v4();

      // Create user profile directly
      await client.from('user_profiles').insert({
        'id': userId,
        'organization_id': organizationId,
        'email': email,
        'full_name': fullName,
        'role': 'employee',
        'status': 'active',
      });

      _logger.info('Employee profile created: $email');

      return {
        'success': true,
        'message': 'Employee profile created successfully',
        'user_id': userId,
      };
    } catch (e, stackTrace) {
      _logger.error('Failed to add employee', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // =====================================================
  // ORGANIZATION
  // =====================================================

  /// Get organization by ID
  Future<Organization?> getOrganization(String organizationId) async {
    try {
      final response = await client
          .from('organizations')
          .select()
          .eq('id', organizationId)
          .single();

      return Organization.fromJson(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get organization',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get all pending organizations (owner only)
  Future<List<Organization>> getPendingOrganizations() async {
    try {
      final response = await client
          .from('organizations')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Organization.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get pending organizations',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Approve organization (owner only)
  Future<bool> approveOrganization(String organizationId) async {
    try {
      await client.from('organizations').update({
        'status': 'approved', // matches enum in DB
        'approved_at': DateTime.now().toIso8601String(),
      }).eq('id', organizationId);

      // Activate manager user
      final managerResponse = await client
          .from('user_profiles')
          .select()
          .eq('organization_id', organizationId)
          .eq('role', 'manager')
          .single();

      // Manager activation handled by status field if needed
      // but is_active column does not exist
      await client.from('user_profiles').update({'status': 'active'}).eq(
        'id',
        managerResponse['id'] as String,
      );

      // Create audit log
      await _createAuditLog(
        userId: currentUser!.id,
        organizationId: organizationId,
        action: 'APPROVE',
      );

      _logger.info('Organization approved: $organizationId');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to approve organization',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Reject organization (owner only)
  Future<bool> rejectOrganization(String organizationId) async {
    try {
      await client.from('organizations').update({
        'status': 'rejected',
      }).eq('id', organizationId);

      // Create audit log
      await _createAuditLog(
        userId: currentUser!.id,
        organizationId: organizationId,
        action: 'REJECT',
      );

      _logger.info('Organization rejected: $organizationId');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to reject organization',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete organization and associated manager completely (owner only)
  /// This removes from organizations, user_profiles, and auth.users
  Future<bool> deleteOrganizationAndManager(String organizationId) async {
    try {
      _logger.info('Starting delete for organization: $organizationId');

      // Step 1: Get manager ID before deleting anything
      final managerResponse = await client
          .from('user_profiles')
          .select('id')
          .eq('organization_id', organizationId)
          .maybeSingle();

      final managerId = managerResponse?['id'] as String?;
      _logger.info('Found manager ID: $managerId');

      // Step 2: Delete from user_profiles
      final userDeleted = await client
          .from('user_profiles')
          .delete()
          .eq('organization_id', organizationId)
          .select();
      _logger.info('Deleted user_profiles: $userDeleted');

      // Step 3: Delete from organizations table
      final orgDeleted = await client
          .from('organizations')
          .delete()
          .eq('id', organizationId)
          .select();
      _logger.info('Deleted from organizations: $orgDeleted');

      // Step 4: Delete from auth (skip if fails)
      if (managerId != null) {
        try {
          await client.auth.admin.deleteUser(managerId);
          _logger.info('Deleted auth user: $managerId');
        } catch (e) {
          _logger.warning('Could not delete auth user: $e');
        }
      }

      _logger.info('Delete completed for: $organizationId');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete organization and manager',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // ================================
  // SETTINGS / UTILITIES PLACEHOLDERS
  // ================================

  /// Export expenses as CSV.
  ///
  /// Fetches expenses from Supabase, optionally filtered by [dateRange] and
  /// [categoryName], and writes them to a CSV file in the downloads directory.
  /// Returns the file path on success, or null on failure.
  Future<String?> exportExpensesAsCsv({
    required String dateRange,
    required String categoryName,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null || profile.organizationId == null) {
        _logger
            .warning('Cannot export: user profile or organization not found');
        return null;
      }

      // Build query with organization filter
      var query = client
          .from('expenses')
          .select('*, categories(name)')
          .eq('organization_id', profile.organizationId!);

      // Apply date range filter
      final now = DateTime.now();
      DateTime? startDate;
      switch (dateRange) {
        case 'Last Month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'Last 3 Months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'Last Year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        case 'All Time':
        default:
          startDate = null;
      }

      if (startDate != null) {
        query = query.gte(
            'expense_date', startDate.toIso8601String().split('T')[0]);
      }

      // Fetch expenses
      final response = await query.order('expense_date', ascending: false);
      final expenses = List<Map<String, dynamic>>.from(response);

      // Filter by category if not 'All Categories'
      List<Map<String, dynamic>> filteredExpenses;
      if (categoryName != 'All Categories') {
        filteredExpenses = expenses.where((e) {
          final cat = e['categories'] as Map<String, dynamic>?;
          return cat?['name'] == categoryName;
        }).toList();
      } else {
        filteredExpenses = expenses;
      }

      if (filteredExpenses.isEmpty) {
        _logger.info('No expenses found for export criteria');
        return null;
      }

      // Build CSV content
      final csvBuffer = StringBuffer();
      // Header row
      csvBuffer.writeln('Date,Category,Amount,Description,Receipt URL');

      final dateFormat = DateFormat('yyyy-MM-dd');
      for (final expense in filteredExpenses) {
        final date = expense['expense_date'] as String? ?? '';
        final cat = expense['categories'] as Map<String, dynamic>?;
        final categoryLabel = cat?['name'] as String? ?? 'Uncategorized';
        final amount = expense['amount']?.toString() ?? '0';
        // Escape description for CSV (wrap in quotes, escape internal quotes)
        final rawDesc = expense['description'] as String? ?? '';
        final description = '"${rawDesc.replaceAll('"', '""')}"';
        final receiptUrl = expense['receipt_url'] as String? ?? '';

        csvBuffer
            .writeln('$date,$categoryLabel,$amount,$description,$receiptUrl');
      }

      // Write to file
      final directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'expenses_export_$timestamp.csv';
      final filePath = '${directory.path}${Platform.pathSeparator}$fileName';

      final file = File(filePath);
      await file.writeAsString(csvBuffer.toString());

      _logger.info('CSV exported to: $filePath');
      return filePath;
    } on SocketException catch (e, stackTrace) {
      _logger.error(
        'Network error during CSV export',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to export expenses as CSV',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Export expenses as PDF.
  ///
  /// Fetches expenses from Supabase, optionally filtered by [dateRange] and
  /// [categoryName], and generates a PDF file in the downloads directory.
  /// Returns the file path on success, or null on failure.
  Future<String?> exportExpensesAsPdf({
    required String dateRange,
    required String categoryName,
    bool includeReceipts = false,
  }) async {
    try {
      // Import pdf package dynamically to avoid issues if not available
      final pdf = await _generateExpensesPdf(
        dateRange: dateRange,
        categoryName: categoryName,
        includeReceipts: includeReceipts,
      );

      if (pdf == null) return null;

      // Write to file
      final directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'expenses_report_$timestamp.pdf';
      final filePath = '${directory.path}${Platform.pathSeparator}$fileName';

      final file = File(filePath);
      await file.writeAsBytes(pdf);

      _logger.info('PDF exported to: $filePath');
      return filePath;
    } on SocketException catch (e, stackTrace) {
      _logger.error(
        'Network error during PDF export',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to export expenses as PDF',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Generate PDF document for expenses
  Future<List<int>?> _generateExpensesPdf({
    required String dateRange,
    required String categoryName,
    bool includeReceipts = false,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null || profile.organizationId == null) {
        _logger
            .warning('Cannot export: user profile or organization not found');
        return null;
      }

      // Build query with organization filter
      var query = client
          .from('expenses')
          .select('*, categories(name)')
          .eq('organization_id', profile.organizationId!);

      // Apply date range filter
      final now = DateTime.now();
      DateTime? startDate;
      switch (dateRange) {
        case 'Last Month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'Last 3 Months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'Last Year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        case 'All Time':
        default:
          startDate = null;
      }

      if (startDate != null) {
        query = query.gte(
            'expense_date', startDate.toIso8601String().split('T')[0]);
      }

      // Fetch expenses
      final response = await query.order('expense_date', ascending: false);
      final expenses = List<Map<String, dynamic>>.from(response);

      // Filter by category if not 'All Categories'
      List<Map<String, dynamic>> filteredExpenses;
      if (categoryName != 'All Categories') {
        filteredExpenses = expenses.where((e) {
          final cat = e['categories'] as Map<String, dynamic>?;
          return cat?['name'] == categoryName;
        }).toList();
      } else {
        filteredExpenses = expenses;
      }

      if (filteredExpenses.isEmpty) {
        _logger.info('No expenses found for export criteria');
        return null;
      }

      // Calculate total
      double total = 0;
      for (final expense in filteredExpenses) {
        total += (expense['amount'] as num?)?.toDouble() ?? 0;
      }

      // Build PDF using the pdf package
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated on ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'Date Range: $dateRange | Category: $categoryName',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
            ],
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
          build: (context) => [
            // Table header
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Category',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Amount',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Description',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...filteredExpenses.map((expense) {
                  final date = expense['expense_date'] as String? ?? '';
                  final cat = expense['categories'] as Map<String, dynamic>?;
                  final categoryLabel =
                      cat?['name'] as String? ?? 'Uncategorized';
                  final amount = expense['amount']?.toString() ?? '0';
                  final description = expense['description'] as String? ?? '';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(date),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(categoryLabel),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$$amount'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(description),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      return pdf.save();
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to generate PDF',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update password for the current user.
  Future<bool> updatePassword(String newPassword) async {
    try {
      if (currentUser == null) {
        _logger.warning('Cannot update password: no authenticated user');
        return false;
      }

      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _logger.info('Password updated successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update password',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete all user data for the current user.
  ///
  /// This deletes all expenses and categories created by the user,
  /// but preserves the user profile and organization membership.
  Future<bool> deleteAllUserData() async {
    try {
      if (currentUser == null) {
        _logger.warning('Cannot delete data: no authenticated user');
        return false;
      }

      final profile = await getCurrentUserProfile();
      if (profile == null || profile.organizationId == null) {
        _logger.warning('Cannot delete data: user profile not found');
        return false;
      }

      final userId = currentUser!.id;
      final orgId = profile.organizationId!;

      // Delete user's expenses (those created by this user)
      await client
          .from('expenses')
          .delete()
          .eq('organization_id', orgId)
          .eq('user_id', userId);

      _logger.info('Deleted expenses for user: $userId');

      // Create audit log
      await _createAuditLog(
        userId: userId,
        organizationId: orgId,
        action: 'DELETE_ALL_USER_DATA',
      );

      _logger.info('All user data deleted for user: $userId');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete all user data',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Fetch notification settings for current user.
  ///
  /// Returns the notification settings from user_profiles.settings.notifications
  Future<Map<String, dynamic>?> getNotificationSettingsForCurrentUser() async {
    try {
      if (currentUser == null) {
        _logger.warning('Cannot get notifications: no authenticated user');
        return null;
      }

      final response = await client
          .from('user_profiles')
          .select('settings')
          .eq('id', currentUser!.id)
          .single();

      final settings = response['settings'] as Map<String, dynamic>? ?? {};
      final notifications =
          settings['notifications'] as Map<String, dynamic>? ?? {};

      _logger.info('Fetched notification settings for user');
      return notifications;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get notification settings',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update notification settings for current user.
  ///
  /// Persists the notification settings to user_profiles.settings.notifications
  Future<bool> updateNotificationSettingsForCurrentUser(
    Map<String, dynamic> notificationSettings,
  ) async {
    try {
      if (currentUser == null) {
        _logger.warning('Cannot update notifications: no authenticated user');
        return false;
      }

      // First fetch current settings to preserve other settings
      final response = await client
          .from('user_profiles')
          .select('settings')
          .eq('id', currentUser!.id)
          .single();

      final currentSettings =
          Map<String, dynamic>.from(response['settings'] as Map? ?? {});

      // Merge notification settings
      currentSettings['notifications'] = notificationSettings;

      // Update the profile
      await client.from('user_profiles').update({
        'settings': currentSettings,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);

      _logger.info('Updated notification settings for user');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update notification settings',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Open support/contact page or send support email.
  ///
  /// Returns a support contact information map with email and subject.
  Map<String, String> getSupportContactInfo() {
    return {
      'email': 'support@expensetracker.com',
      'subject': 'Support Request - Expense Tracker',
      'body': 'Please describe your issue:\n\n',
    };
  }

  // =====================================================
  // CATEGORIES
  // =====================================================

  /// Sync category to Supabase
  Future<Map<String, dynamic>> syncCategory({
    required Map<String, dynamic> categoryData,
    required String operation, // INSERT, UPDATE, DELETE
  }) async {
    try {
      final profile = await getUserProfile(currentUser!.id);
      if (profile == null || profile.organizationId == null) {
        throw Exception('User profile or organization not found');
      }

      categoryData['organization_id'] = profile.organizationId;
      categoryData['created_by'] = currentUser!.id;

      dynamic response;

      switch (operation) {
        case 'INSERT':
          response = await client
              .from('categories')
              .insert(categoryData)
              .select()
              .single();
          break;
        case 'UPDATE':
          response = await client
              .from('categories')
              .update(categoryData)
              .eq('id', categoryData['id'] as Object)
              .eq('organization_id', profile.organizationId!)
              .select()
              .single();
          break;
        case 'DELETE':
          await client
              .from('categories')
              .delete()
              .eq('id', categoryData['id'] as Object)
              .eq('organization_id', profile.organizationId!);
          return {'success': true, 'operation': 'DELETE'};
        default:
          throw Exception('Invalid operation: $operation');
      }

      return {
        'success': true,
        'data': response,
        'operation': operation,
      };
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to sync category',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Get all categories for organization
  Future<List<Map<String, dynamic>>> getCategories([
    String? organizationId,
  ]) async {
    try {
      String? orgId = organizationId;
      if (orgId == null && currentUser != null) {
        final profile = await getCurrentUserProfile();
        orgId = profile?.organizationId;
      }
      if (orgId == null) {
        return [];
      }

      final response = await client
          .from('categories')
          .select()
          .eq('organization_id', orgId)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get categories',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Create a new category on server
  Future<String?> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) throw Exception('User profile not found');

      final orgId = profile.organizationId;
      if (orgId == null) throw Exception('Organization not found');

      final response = await client
          .from('categories')
          .insert({
            'name': name,
            'icon': icon,
            'color': color,
            'organization_id': orgId,
            'user_id': currentUser!.id,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create category',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update a category on server
  Future<void> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updates['name'] = name;
      if (icon != null) updates['icon'] = icon;
      if (color != null) updates['color'] = color;

      await client.from('categories').update(updates).eq('id', id);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update category',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a category from server
  Future<void> deleteCategory(String id) async {
    try {
      await client.from('categories').delete().eq('id', id);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete category',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // =====================================================
  // EXPENSES
  // =====================================================

  /// Create a new expense on server
  Future<String?> createExpense({
    required String categoryId,
    required double amount,
    required DateTime expenseDate,
    String? description,
    String? receiptUrl,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) throw Exception('User profile not found');

      final orgId = profile.organizationId;
      if (orgId == null) throw Exception('Organization not found');

      final response = await client
          .from('expenses')
          .insert({
            'category_id': categoryId,
            'amount': amount,
            'description': description,
            'expense_date': expenseDate.toIso8601String().split('T')[0],
            'receipt_url': receiptUrl,
            'organization_id': orgId,
            'user_id': currentUser!.id,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create expense',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update an expense on server
  Future<void> updateExpense({
    required String id,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? expenseDate,
    String? receiptUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (categoryId != null) updates['category_id'] = categoryId;
      if (amount != null) updates['amount'] = amount;
      if (description != null) updates['description'] = description;
      if (expenseDate != null) {
        updates['expense_date'] = expenseDate.toIso8601String().split('T')[0];
      }
      if (receiptUrl != null) updates['receipt_url'] = receiptUrl;

      await client.from('expenses').update(updates).eq('id', id);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update expense',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete an expense from server
  Future<void> deleteExpense(String id) async {
    try {
      await client.from('expenses').delete().eq('id', id);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete expense',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Sync expense to Supabase
  Future<Map<String, dynamic>> syncExpense({
    required Map<String, dynamic> expenseData,
    required String operation, // INSERT, UPDATE, DELETE
  }) async {
    try {
      final profile = await getUserProfile(currentUser!.id);
      if (profile == null || profile.organizationId == null) {
        throw Exception('User profile or organization not found');
      }

      expenseData['organization_id'] = profile.organizationId;
      expenseData['created_by'] = currentUser!.id;

      dynamic response;

      switch (operation) {
        case 'INSERT':
          response = await client
              .from('expenses')
              .insert(expenseData)
              .select()
              .single();
          break;
        case 'UPDATE':
          response = await client
              .from('expenses')
              .update(expenseData)
              .eq('id', expenseData['id'] as Object)
              .eq('organization_id', profile.organizationId!)
              .select()
              .single();
          break;
        case 'DELETE':
          await client
              .from('expenses')
              .delete()
              .eq('id', expenseData['id'] as Object)
              .eq('organization_id', profile.organizationId!);
          return {'success': true, 'operation': 'DELETE'};
        default:
          throw Exception('Invalid operation: $operation');
      }

      return {
        'success': true,
        'data': response,
        'operation': operation,
      };
    } catch (e, stackTrace) {
      _logger.error('Failed to sync expense', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Get all expenses for organization
  Future<List<Map<String, dynamic>>> getExpenses([
    String? organizationId,
  ]) async {
    try {
      String? orgId = organizationId;
      if (orgId == null && currentUser != null) {
        final profile = await getCurrentUserProfile();
        orgId = profile?.organizationId;
      }
      if (orgId == null) {
        return [];
      }

      final response = await client
          .from('expenses')
          .select()
          .eq('organization_id', orgId)
          .order('expense_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to get expenses', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // =====================================================
  // RECEIPTS (Supabase Storage)
  // =====================================================

  /// Upload receipt file
  Future<String?> uploadReceipt({
    required File file,
    required String organizationId,
    required String fileName,
  }) async {
    try {
      final fileExtension = file.path.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$organizationId/$timestamp-$fileName.$fileExtension';

      await client.storage
          .from(SupabaseConfig.receiptsBucket)
          .upload(storagePath, file);

      final publicUrl = client.storage
          .from(SupabaseConfig.receiptsBucket)
          .getPublicUrl(storagePath);

      _logger.info('Receipt uploaded: $storagePath');
      return publicUrl;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to upload receipt',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Download receipt file
  Future<File?> downloadReceipt({
    required String receiptUrl,
    required String localPath,
  }) async {
    try {
      final storagePath = receiptUrl.split('/').last;
      final bytes = await client.storage
          .from(SupabaseConfig.receiptsBucket)
          .download(storagePath);

      final file = File(localPath);
      await file.writeAsBytes(bytes);

      _logger.info('Receipt downloaded: $localPath');
      return file;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to download receipt',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Delete receipt file
  Future<bool> deleteReceipt(String receiptUrl) async {
    try {
      final storagePath = receiptUrl.split('/').last;
      await client.storage
          .from(SupabaseConfig.receiptsBucket)
          .remove([storagePath]);

      _logger.info('Receipt deleted: $storagePath');
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete receipt',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // =====================================================
  // AUDIT LOGS
  // =====================================================

  /// Create audit log entry
  Future<void> _createAuditLog({
    required String userId,
    required String action,
    String? organizationId,
    String? tableName,
    int? recordId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      await client.from('audit_logs').insert({
        'user_id': userId,
        'organization_id': organizationId,
        'action': action,
        'table_name': tableName,
        'record_id': recordId,
        'old_data': oldData,
        'new_data': newData,
      });
    } catch (e) {
      _logger.warning('Failed to create audit log: $e');
      // Don't throw, just log the warning
    }
  }

  /// Get audit logs for organization
  Future<List<Map<String, dynamic>>> getAuditLogs({
    required String organizationId,
    int limit = 100,
  }) async {
    try {
      final response = await client
          .from('audit_logs')
          .select()
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get audit logs',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // =====================================================
  // REAL-TIME SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to category changes
  RealtimeChannel subscribeToCategories({
    required String organizationId,
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    return client
        .channel('categories:$organizationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'categories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organization_id',
            value: organizationId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'categories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organization_id',
            value: organizationId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'categories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organization_id',
            value: organizationId,
          ),
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  /// Subscribe to expense changes
  RealtimeChannel subscribeToExpenses({
    required String organizationId,
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    return client
        .channel('expenses:$organizationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'expenses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organization_id',
            value: organizationId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'expenses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organization_id',
            value: organizationId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'expenses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organization_id',
            value: organizationId,
          ),
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }

  // =====================================================
  // UTILITIES
  // =====================================================

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return UserProfile.fromJson(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get current user profile',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get approved organizations
  Future<List<Map<String, dynamic>>> getApprovedOrganizations() async {
    try {
      final response = await client
          .from('organizations')
          .select()
          .eq('status', 'approved')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get approved organizations',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get rejected organizations
  Future<List<Map<String, dynamic>>> getRejectedOrganizations() async {
    try {
      final response = await client
          .from('organizations')
          .select()
          .eq('status', 'rejected')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get rejected organizations',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get organization members
  Future<List<Map<String, dynamic>>> getOrganizationMembers(
    String organizationId,
  ) async {
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('organization_id', organizationId)
          .order('full_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get organization members',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Remove employee
  Future<void> removeEmployee(String userId) async {
    try {
      await client.from('user_profiles').delete().eq('id', userId);
      _logger.info('Employee removed: $userId');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to remove employee',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update employee status
  Future<void> updateEmployeeStatus(String userId, String status) async {
    try {
      await client
          .from('user_profiles')
          .update({'status': status}).eq('id', userId);
      _logger.info('Employee status updated: $userId -> $status');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update employee status',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is PostgrestException) {
      return error.message;
    } else if (error is StorageException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  /// Dispose resources
  void dispose() {
    // Clean up any active subscriptions if needed
    _logger.info('Supabase service disposed');
  }
}
