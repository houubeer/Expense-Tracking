import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:expense_tracking_desktop_app/config/supabase_config.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/organization.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';

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
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  static final SupabaseService _instance = SupabaseService._internal();

  final _logger = LoggerService.instance;
  SupabaseClient? _client;

  /// Initialize Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: SupabaseConfig.debugMode,
      );
      _client = Supabase.instance.client;
      _logger.info('Supabase initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize Supabase',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // EXPORTS - PDF
  // =====================================================

  /// Export expenses as a PDF file (includes receipts/images when available)
  /// Returns the local file path on success, or null on failure.
  Future<String?> exportExpensesAsPdf({
    String? dateRange,
    String? categoryName,
    String? organizationId,
    bool includeReceipts = true,
  }) async {
    try {
      String? orgId = organizationId;
      if (orgId == null) {
        final profile = await getCurrentUserProfile();
        orgId = profile?['organization_id'] as String?;
      }
      if (orgId == null) throw Exception('Organization not found');

      // Build base query
      var query = client
          .from('expenses')
          .select(
              'id,expense_date,amount,description,receipt_url,category_id,created_at,updated_at,user_id')
          .eq('organization_id', orgId);

      // Date range filter (same logic as CSV)
      final DateTime now = DateTime.now();
      DateTime? fromDate;
      if (dateRange == 'Last Month') {
        fromDate = DateTime(now.year, now.month - 1, now.day);
      } else if (dateRange == 'Last 3 Months') {
        fromDate = DateTime(now.year, now.month - 3, now.day);
      } else if (dateRange == 'Last Year') {
        fromDate = DateTime(now.year - 1, now.month, now.day);
      }
      if (fromDate != null) {
        query =
            query.gte('expense_date', fromDate.toIso8601String().split('T')[0]);
      }

      // Category filter (resolve name -> id)
      if (categoryName != null && categoryName != 'All Categories') {
        final catResp = await client
            .from('categories')
            .select()
            .eq('organization_id', orgId)
            .eq('name', categoryName)
            .maybeSingle();
        if (catResp != null && catResp['id'] != null) {
          query = query.eq('category_id', catResp['id'] as String);
        }
      }

      final resp = await query.order('expense_date', ascending: false);
      final rows = List<Map<String, dynamic>>.from(resp as List);

      // Fetch category names for mapping
      final categoryIds = rows
          .map((r) => r['category_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();
      final Map<String, String> catMap = {};
      if (categoryIds.isNotEmpty) {
        final cats = await client
            .from('categories')
            .select()
            .eq('organization_id', orgId)
            .order('name');
        for (final c in cats as List) {
          final cid = c['id']?.toString() ?? '';
          if (categoryIds.contains(cid)) {
            catMap[cid] = c['name'] as String? ?? '';
          }
        }
      }

      // Build PDF
      final doc = pw.Document();

      // Title page / header
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            final header = pw.Header(
              level: 0,
              child: pw.Text('Expenses Export',
                  style: const pw.TextStyle(fontSize: 24)),
            );

            // Table rows
            final tableHeaders = [
              'ID',
              'Date',
              'Amount',
              'Category',
              'Description',
              'Receipt',
              'User',
            ];

            final tableData = rows.map((r) {
              final id = r['id']?.toString() ?? '';
              final date = r['expense_date']?.toString() ?? '';
              final amount = r['amount']?.toString() ?? '';
              final catId = r['category_id'] as String?;
              final category = catId != null ? (catMap[catId] ?? catId) : '';
              final description = r['description']?.toString() ?? '';
              final receipt = r['receipt_url']?.toString() ?? '';
              final userId = r['user_id']?.toString() ?? '';
              return [id, date, amount, category, description, receipt, userId];
            }).toList();

            return [
              header,
              pw.SizedBox(height: 8),
              pw.Text('Generated: ${DateTime.now().toIso8601String()}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );

      // Add individual receipt pages (if requested)
      if (includeReceipts) {
        for (final r in rows) {
          final receiptUrl = r['receipt_url']?.toString();
          if (receiptUrl == null || receiptUrl.isEmpty) continue;

          try {
            // Download image bytes (HttpClient)
            final uri = Uri.parse(receiptUrl);
            final httpClient = HttpClient();
            final request = await httpClient.getUrl(uri);
            final response = await request.close();
            if (response.statusCode == 200) {
              final bytes = await response.fold<List<int>>(
                  [], (prev, element) => prev..addAll(element));
              final imgData = Uint8List.fromList(bytes);

              final img = pw.MemoryImage(imgData);

              // Add a page with the receipt image and some metadata
              doc.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context ctx) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Receipt for Expense ID: ${r['id']}',
                            style: const pw.TextStyle(fontSize: 16)),
                        pw.SizedBox(height: 8),
                        pw.Text('Date: ${r['expense_date']?.toString() ?? ''}'),
                        pw.Text('Amount: ${r['amount']?.toString() ?? ''}'),
                        pw.SizedBox(height: 12),
                        pw.Center(child: pw.Image(img)),
                        pw.SizedBox(height: 12),
                        pw.Text(
                            'Description: ${r['description']?.toString() ?? ''}'),
                      ],
                    );
                  },
                ),
              );
            }
          } catch (e) {
            // Ignore individual image failures but log
            _logger.warning(
                'Failed to download/attach receipt image: $receiptUrl',
                error: e);
          }
        }
      }

      // Save PDF to Downloads
      final pdfBytes = await doc.save();
      final userProfileEnv = Platform.environment['USERPROFILE'] ?? '.';
      final downloadsDir = '$userProfileEnv${Platform.pathSeparator}Downloads';
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'expenses-export-$timestamp.pdf';
      final path = '$downloadsDir${Platform.pathSeparator}$fileName';

      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(pdfBytes, flush: true);

      _logger.info('Expenses exported to PDF: $path');
      return path;
    } catch (e, st) {
      _logger.error('Failed to export expenses as PDF',
          error: e, stackTrace: st);
      return null;
    }
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
        'is_active': false, // Will be activated when org is approved
      });

      // Create organization (pending approval) with manager_name from full_name
      final orgResponse = await client
          .from('organizations')
          .insert({
            'name': organizationName,
            'manager_email': trimmedEmail,
            'manager_name': fullName,
            'status': 'pending',
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

      // Check if user is active
      if (!userProfile.isActive && !userProfile.isOwner) {
        throw Exception(
          'Your account is not yet activated. Please wait for approval.',
        );
      }

      // Create audit log
      await _createAuditLog(
        userId: userProfile.id,
        organizationId: userProfile.organizationId,
        action: 'LOGIN',
      );

      _logger.info('User signed in: $email');

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
      _logger.error('Password reset request failed',
          error: e, stackTrace: stackTrace);
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

      final currentRole = currentProfile['role'] as String?;
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
        final currentOrgId = currentProfile['organization_id'] as String?;
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
      _logger.error('Employee password reset failed',
          error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // =====================================================
  // USER PROFILE
  // =====================================================

  /// Update the current user's password.
  /// Returns true on success.
  Future<bool> updatePassword(String newPassword) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');

      // Use auth client to update the user's password
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _logger.info('User password updated: ${currentUser!.id}');
      return true;
    } catch (e, st) {
      _logger.error('Failed to update password', error: e, stackTrace: st);
      return false;
    }
  }

  /// Delete all data owned by the current user (expenses).
  /// This is intentionally conservative: it only removes rows directly
  /// linked to the user's id to avoid accidentally wiping organization-wide data.
  Future<bool> deleteAllUserData() async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      final uid = currentUser!.id;

      // Delete user's expenses
      await client.from('expenses').delete().eq('user_id', uid);

      _logger.info('Deleted all expense data for user: $uid');
      return true;
    } catch (e, st) {
      _logger.error('Failed to delete user data', error: e, stackTrace: st);
      return false;
    }
  }

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

  /// Get notification settings for the current user (stored in
  /// user_profiles.settings -> notifications)
  Future<Map<String, dynamic>?> getNotificationSettingsForCurrentUser() async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return null;
      final settings = (profile['settings'] as Map?)?.cast<String, dynamic>();
      if (settings == null) return null;
      final notifications = (settings['notifications'] as Map?)?.cast<String, dynamic>();
      return notifications;
    } catch (e, st) {
      _logger.error('Failed to get notification settings', error: e, stackTrace: st);
      return null;
    }
  }

  /// Update the notification settings for the current user. This merges the
  /// provided `notifications` map into the existing `settings` JSON column
  /// under the `notifications` key.
  Future<bool> updateNotificationSettingsForCurrentUser(Map<String, dynamic> notifications) async {
    try {
      if (currentUser == null) throw Exception('Not authenticated');
      final profile = await getCurrentUserProfile();
      final existingSettings = (profile?['settings'] as Map?)?.cast<String, dynamic>() ?? {};
      final merged = Map<String, dynamic>.from(existingSettings);
      merged['notifications'] = notifications;

      await client.from('user_profiles').update({'settings': merged}).eq('id', currentUser!.id);
      _logger.info('Updated notification settings for user: ${currentUser!.id}');
      return true;
    } catch (e, st) {
      _logger.error('Failed to update notification settings', error: e, stackTrace: st);
      return false;
    }
  }

  /// Add employee (manager only)
  Future<Map<String, dynamic>> addEmployee({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  }) async {
    try {
      // Create auth user
      final authResponse = await client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create employee account');
      }

      // Create user profile
      await client.from('user_profiles').insert({
        'id': authResponse.user!.id,
        'organization_id': organizationId,
        'email': email,
        'full_name': fullName,
        'role': 'employee',
        'is_active': true,
      });

      _logger.info('Employee added: $email');

      return {
        'success': true,
        'message': 'Employee added successfully',
        'user_id': authResponse.user!.id,
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
        'status': 'approved',
        'approved_by': currentUser!.id,
        'approved_at': DateTime.now().toIso8601String(),
      }).eq('id', organizationId);

      // Activate manager user
      final managerResponse = await client
          .from('user_profiles')
          .select()
          .eq('organization_id', organizationId)
          .eq('role', 'manager')
          .single();

      await client.from('user_profiles').update({'is_active': true}).eq(
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
        orgId = profile?['organization_id'] as String?;
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

      final orgId = profile['organization_id'] as String?;
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

      final orgId = profile['organization_id'] as String?;
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
        orgId = profile?['organization_id'] as String?;
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

  /// Export expenses as CSV file and save to the user's Downloads folder.
  /// Returns the local file path on success, or null on failure.
  Future<String?> exportExpensesAsCsv({
    String dateRange = 'All Time',
    String? categoryName,
    String? organizationId,
  }) async {
    try {
      String? orgId = organizationId;
      if (orgId == null) {
        final profile = await getCurrentUserProfile();
        orgId = profile?['organization_id'] as String?;
      }
      if (orgId == null) throw Exception('Organization not found');

      // Build base query
      var query = client
          .from('expenses')
          .select(
            'id,expense_date,amount,description,receipt_url,category_id,created_at,updated_at,user_id',
          )
          .eq('organization_id', orgId);

      // Date range filter
      final DateTime now = DateTime.now();
      DateTime? fromDate;
      if (dateRange == 'Last Month') {
        fromDate = DateTime(now.year, now.month - 1, now.day);
      } else if (dateRange == 'Last 3 Months') {
        fromDate = DateTime(now.year, now.month - 3, now.day);
      } else if (dateRange == 'Last Year') {
        fromDate = DateTime(now.year - 1, now.month, now.day);
      }
      if (fromDate != null) {
        query =
            query.gte('expense_date', fromDate.toIso8601String().split('T')[0]);
      }

      // Category filter (resolve name -> id)
      if (categoryName != null && categoryName != 'All Categories') {
        final catResp = await client
            .from('categories')
            .select()
            .eq('organization_id', orgId)
            .eq('name', categoryName)
            .maybeSingle();
        if (catResp != null && catResp['id'] != null) {
          query = query.eq('category_id', catResp['id'] as String);
        }
      }

      final resp = await query.order('expense_date', ascending: false);
      final rows = List<Map<String, dynamic>>.from(resp as List);

      // Fetch category names for mapping
      final categoryIds = rows
          .map((r) => r['category_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();
      final Map<String, String> catMap = {};
      if (categoryIds.isNotEmpty) {
        // Supabase client version may not expose a direct `in_` helper on the
        // PostgrestFilterBuilder in this SDK; fetch categories for the
        // organization and filter locally by the set of ids.
        final cats = await client
            .from('categories')
            .select()
            .eq('organization_id', orgId)
            .order('name');
        for (final c in cats as List) {
          final cid = c['id']?.toString() ?? '';
          if (categoryIds.contains(cid)) {
            catMap[cid] = c['name'] as String? ?? '';
          }
        }
      }

      // Build CSV
      final sb = StringBuffer();
      sb.writeln(
        'id,expense_date,amount,category,description,receipt_url,created_at,updated_at,user_id',
      );
      String escape(String? v) {
        if (v == null) return '';
        final s = v.replaceAll('"', '""');
        if (s.contains(',') || s.contains('\n') || s.contains('"')) {
          return '"$s"';
        }
        return s;
      }

      for (final r in rows) {
        final id = r['id']?.toString() ?? '';
        final date = r['expense_date']?.toString() ?? '';
        final amount = r['amount']?.toString() ?? '';
        final catId = r['category_id'] as String?;
        final category = catId != null ? (catMap[catId] ?? catId) : '';
        final description = r['description']?.toString() ?? '';
        final receipt = r['receipt_url']?.toString() ?? '';
        final createdAt = r['created_at']?.toString() ?? '';
        final updatedAt = r['updated_at']?.toString() ?? '';
        final userId = r['user_id']?.toString() ?? '';

        sb.writeln(
          [
            escape(id),
            escape(date),
            escape(amount),
            escape(category),
            escape(description),
            escape(receipt),
            escape(createdAt),
            escape(updatedAt),
            escape(userId),
          ].join(','),
        );
      }

      // Save to Downloads
      final userProfile = Platform.environment['USERPROFILE'] ?? '.';
      final downloadsDir = '$userProfile${Platform.pathSeparator}Downloads';
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'expenses-export-$timestamp.csv';
      final path = '$downloadsDir${Platform.pathSeparator}$fileName';

      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsString(sb.toString(), flush: true);

      _logger.info('Expenses exported to CSV: $path');
      return path;
    } catch (e, stackTrace) {
      _logger.error('Failed to export expenses as CSV',
          error: e, stackTrace: stackTrace);
      return null;
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
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return response;
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
  Future<void> updateEmployeeStatus(String userId, bool isActive) async {
    try {
      await client
          .from('user_profiles')
          .update({'is_active': isActive}).eq('id', userId);
      _logger.info('Employee status updated: $userId -> $isActive');
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
