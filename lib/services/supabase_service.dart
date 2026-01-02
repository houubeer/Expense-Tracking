import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/config/supabase_config.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/organization.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// - Categories & Expenses CRUD
/// - Receipt upload/download
/// - Real-time subscriptions
/// - Conflict resolution
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

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
      // Create auth user
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create organization (pending approval)
      final orgResponse = await client
          .from('organizations')
          .insert({
            'name': organizationName,
            'manager_email': email,
            'status': 'pending',
          })
          .select()
          .single();

      // Create user profile
      await client.from('user_profiles').insert({
        'id': authResponse.user!.id,
        'organization_id': orgResponse['id'],
        'email': email,
        'full_name': fullName,
        'role': 'manager',
        'is_active': false, // Will be activated when org is approved
      });

      _logger.info('Manager signup successful: $email');

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
            'Your account is not yet activated. Please wait for approval.');
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

  /// Request password reset email
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent',
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

  /// Reset password using token (from within the app when session is established via reset link)
  Future<Map<String, dynamic>> resetPassword({
    required String newPassword,
  }) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return {
        'success': true,
        'message': 'Password reset successful',
      };
    } catch (e, stackTrace) {
      _logger.error('Password reset failed', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Update current user password
  Future<bool> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e, stackTrace) {
      _logger.error('Update password failed', error: e, stackTrace: stackTrace);
      return false;
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
      _logger.error('Failed to get user profile',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return getUserProfile(currentUser!.id);
  }

  /// Get organization members
  Future<List<UserProfile>> getOrganizationMembers(
      String organizationId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('organization_id', organizationId);

      return response.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to get organization members',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Remove an employee from the organization
  Future<bool> removeEmployee(String userId) async {
    try {
      await client.from('user_profiles').delete().eq('id', userId);

      _logger.info('Employee removed: $userId');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to remove employee',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update employee status (active/inactive)
  Future<bool> updateEmployeeStatus(String userId, bool isActive) async {
    try {
      await client
          .from('user_profiles')
          .update({'is_active': isActive}).eq('id', userId);

      _logger.info('Employee status updated: $userId -> $isActive');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update employee status',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Reset an employee's password (manager only)
  Future<Map<String, dynamic>> resetEmployeePassword({
    required String employeeId,
    required String newPassword,
  }) async {
    try {
      await client.auth.admin.updateUserById(
        employeeId,
        attributes: AdminUserAttributes(password: newPassword),
      );
      return {
        'success': true,
        'message': 'Employee password reset successful',
      };
    } catch (e, stackTrace) {
      _logger.error('Failed to reset employee password',
          error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Delete all data for the current user
  Future<bool> deleteAllUserData() async {
    try {
      if (currentUser == null) return false;

      // Delete expenses first (due to foreign key constraints)
      await client.from('expenses').delete().eq('created_by', currentUser!.id);

      // Categories created by the user
      await client
          .from('categories')
          .delete()
          .eq('created_by', currentUser!.id);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete user data',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final json = profile.toJson();

      // Remove all fields except those that are meant to be updated by the user
      final allowedFields = [
        'full_name',
        'settings',
        'phone',
        'avatar_url',
        'updated_at'
      ];
      final updateData = <String, dynamic>{};

      for (var field in allowedFields) {
        if (json.containsKey(field)) {
          updateData[field] = json[field];
        }
      }

      // Ensure full_name is not null as it's NOT NULL in DB
      if (updateData['full_name'] == null) {
        updateData['full_name'] = profile.email.split('@').first;
      }

      await client
          .from('user_profiles')
          .update(updateData)
          .eq('id', profile.id);

      _logger.info('User profile updated successfully for: ${profile.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update user profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Upload avatar image
  Future<String?> uploadAvatar(File file, String userId) async {
    try {
      // Ensure bucket exists
      try {
        await client.storage.getBucket('avatars');
      } catch (_) {
        try {
          await client.storage.createBucket(
            'avatars',
            const BucketOptions(
              public: true,
              fileSizeLimit: '5242880',
              allowedMimeTypes: ['image/*'],
            ),
          );
        } catch (e) {
          _logger.warning('Could not create avatars bucket: $e');
        }
      }

      final fileExt = file.path.split('.').last;
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await client.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = client.storage.from('avatars').getPublicUrl(fileName);
      return imageUrl;
    } catch (e, stackTrace) {
      _logger.error('Failed to upload avatar',
          error: e, stackTrace: stackTrace);
      rethrow;
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
      _logger.error('Failed to get organization',
          error: e, stackTrace: stackTrace);
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

      return (response as List<dynamic>)
          .map((json) => Organization.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to get pending organizations',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all approved organizations (owner only)
  Future<List<Map<String, dynamic>>> getApprovedOrganizations() async {
    try {
      final response = await client
          .from('organizations')
          .select()
          .eq('status', 'approved')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to get approved organizations',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all rejected organizations (owner only)
  Future<List<Map<String, dynamic>>> getRejectedOrganizations() async {
    try {
      final response = await client
          .from('organizations')
          .select()
          .eq('status', 'rejected')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to get rejected organizations',
          error: e, stackTrace: stackTrace);
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
          'id', managerResponse['id'] as Object);

      // Create audit log
      await _createAuditLog(
        userId: currentUser!.id,
        organizationId: organizationId,
        action: 'APPROVE',
      );

      _logger.info('Organization approved: $organizationId');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to approve organization',
          error: e, stackTrace: stackTrace);
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
      _logger.error('Failed to reject organization',
          error: e, stackTrace: stackTrace);
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
      _logger.error('Failed to sync category',
          error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  /// Get all categories for organization
  Future<List<Map<String, dynamic>>> getCategories(
      String organizationId) async {
    try {
      final response = await client
          .from('categories')
          .select()
          .eq('organization_id', organizationId)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to get categories',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Create a new category
  Future<String?> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null || profile.organizationId == null) {
        throw Exception('User profile or organization not found');
      }

      final response = await client
          .from('categories')
          .insert({
            'name': name,
            'icon': icon,
            'color': color,
            'organization_id': profile.organizationId,
            'created_by': currentUser!.id,
          })
          .select()
          .single();

      return response['id']?.toString();
    } catch (e, stackTrace) {
      _logger.error('Failed to create category',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Update an existing category
  Future<bool> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (icon != null) updateData['icon'] = icon;
      if (color != null) updateData['color'] = color;

      if (updateData.isEmpty) return true;

      await client.from('categories').update(updateData).eq('id', id);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update category',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    try {
      await client.from('categories').delete().eq('id', id);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete category',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // =====================================================
  // EXPENSES
  // =====================================================

  /// Create a new expense
  Future<String?> createExpense({
    required String categoryId,
    required double amount,
    String? description,
    String? notes,
    required DateTime expenseDate,
    String? receiptUrl,
    bool isReimbursable = false,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null || profile.organizationId == null) {
        throw Exception('User profile or organization not found');
      }

      final response = await client
          .from('expenses')
          .insert({
            'category_id': categoryId,
            'amount': amount,
            'description': description,
            'notes': notes,
            'date': expenseDate.toIso8601String(),
            'receipt_url': receiptUrl,
            'is_reimbursable': isReimbursable,
            'organization_id': profile.organizationId,
            'created_by': currentUser!.id,
          })
          .select()
          .single();

      return response['id']?.toString();
    } catch (e, stackTrace) {
      _logger.error('Failed to create expense',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Update an existing expense
  Future<bool> updateExpense({
    required String id,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? expenseDate,
    String? receiptUrl,
    bool? isReimbursable,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (categoryId != null) updateData['category_id'] = categoryId;
      if (amount != null) updateData['amount'] = amount;
      if (description != null) updateData['description'] = description;
      if (expenseDate != null)
        updateData['date'] = expenseDate.toIso8601String();
      if (receiptUrl != null) updateData['receipt_url'] = receiptUrl;
      if (isReimbursable != null)
        updateData['is_reimbursable'] = isReimbursable;

      if (updateData.isEmpty) return true;

      await client.from('expenses').update(updateData).eq('id', id);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update expense',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(String id) async {
    try {
      await client.from('expenses').delete().eq('id', id);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete expense',
          error: e, stackTrace: stackTrace);
      return false;
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

  /// Get all expenses for organization with optional date range filtering
  Future<List<Map<String, dynamic>>> getExpenses(
    String organizationId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from('expenses')
          .select('*, receipts(*)')
          .eq('organization_id', organizationId);

      // Apply date range filtering if provided
      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query.order('date', ascending: false);

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
      _logger.error('Failed to upload receipt',
          error: e, stackTrace: stackTrace);
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
      _logger.error('Failed to download receipt',
          error: e, stackTrace: stackTrace);
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
      _logger.error('Failed to delete receipt',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // =====================================================
  // AUDIT LOGS
  // =====================================================

  /// Create audit log entry
  Future<void> _createAuditLog({
    required String userId,
    String? organizationId,
    required String action,
    String? tableName,
    int? recordId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? description,
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
        'description': description,
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
      _logger.error('Failed to get audit logs',
          error: e, stackTrace: stackTrace);
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

  /// Get notification settings for current user
  Future<Map<String, dynamic>?> getNotificationSettingsForCurrentUser() async {
    try {
      if (currentUser == null) return null;
      final profile = await getCurrentUserProfile();
      if (profile == null) return null;
      return profile.settings['notifications'] != null
          ? Map<String, dynamic>.from(profile.settings['notifications'] as Map)
          : null;
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification settings',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Update notification settings for current user
  Future<bool> updateNotificationSettingsForCurrentUser(
      Map<String, dynamic> notifications) async {
    try {
      if (currentUser == null) return false;
      final profile = await getCurrentUserProfile();
      if (profile == null) return false;

      final updatedSettings = Map<String, dynamic>.from(profile.settings);
      updatedSettings['notifications'] = notifications;

      final updatedProfile = profile.copyWith(settings: updatedSettings);
      return updateUserProfile(updatedProfile);
    } catch (e, stackTrace) {
      _logger.error('Failed to update notification settings',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Export expenses as CSV
  Future<String?> exportExpensesAsCsv({
    required String dateRange,
    required String categoryName,
  }) async {
    try {
      if (currentUser == null) return null;

      final profile = await getCurrentUserProfile();
      if (profile == null) return null;

      // Calculate start date based on dateRange
      DateTime? startDate;
      final now = DateTime.now();
      switch (dateRange) {
        case 'Last 7 Days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last Month':
        case 'Last 30 Days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'Last 3 Months':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Last Year':
        case 'This Year':
          startDate = now.subtract(const Duration(days: 365));
          break;
      }

      var query = client
          .from('expenses')
          .select('*, categories(name)')
          .eq('organization_id', profile.organizationId ?? '');

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      final response = await query;
      final List<dynamic> allData = response as List<dynamic>;

      // Filter by category if needed
      var data = allData;
      if (categoryName != 'All Categories') {
        data = data.where((e) {
          final catName = e['categories']?['name']?.toString() ?? 'Unknown';
          return catName.toLowerCase() == categoryName.toLowerCase();
        }).toList();
      }

      if (data.isEmpty) {
        _logger.warning('No expenses found for export with these filters');
        return null;
      }

      // Create CSV content
      final buffer = StringBuffer();
      buffer.writeln('ID,Date,Category,Description,Amount,Notes');

      for (var expense in data) {
        final category = expense['categories']?['name'] ?? 'Unknown';
        final description =
            (expense['description'] ?? '').toString().replaceAll('"', '""');
        final notes = (expense['notes'] ?? '').toString().replaceAll('"', '""');
        buffer.writeln(
            '${expense['id']},${expense['date']},$category,"$description",${expense['amount']},"$notes"');
      }

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final exportDir =
          Directory(p.join(dir.path, 'ExpenseTracker', 'Exports'));
      if (!await exportDir.exists()) await exportDir.create(recursive: true);

      final fileName =
          'expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      _logger.info('CSV exported to: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      _logger.error('Failed to export CSV', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Export expenses as PDF
  Future<String?> exportExpensesAsPdf({
    required String dateRange,
    required String categoryName,
    bool includeReceipts = false,
  }) async {
    try {
      if (currentUser == null) return null;

      final profile = await getCurrentUserProfile();
      if (profile == null) return null;

      // Calculate filtering
      DateTime? startDate;
      final now = DateTime.now();
      switch (dateRange) {
        case 'Last 7 Days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last Month':
        case 'Last 30 Days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'Last 3 Months':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Last Year':
        case 'This Year':
          startDate = now.subtract(const Duration(days: 365));
          break;
      }

      var query = client
          .from('expenses')
          .select('*, categories(name)')
          .eq('organization_id', profile.organizationId ?? '');

      if (startDate != null)
        query = query.gte('date', startDate.toIso8601String());

      final response = await query;
      final List<dynamic> allData = response as List<dynamic>;

      // Filter by category if needed
      var data = allData;
      if (categoryName != 'All Categories') {
        data = data.where((e) {
          final catName = e['categories']?['name']?.toString() ?? 'Unknown';
          return catName.toLowerCase() == categoryName.toLowerCase();
        }).toList();
      }

      if (data.isEmpty) {
        _logger.warning('No expenses found for PDF export');
        return null;
      }

      // Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Header(level: 0, child: pw.Text('Expense Report - $dateRange')),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Category', 'Description', 'Amount'],
              data: data
                  .map((e) => [
                        (e['date'] ?? '').toString().split('T').first,
                        e['categories']?['name']?.toString() ?? 'Unknown',
                        e['description']?.toString() ?? '',
                        '${e['amount'] ?? 0.00} DZD',
                      ])
                  .toList(),
            ),
          ],
        ),
      );

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final exportDir =
          Directory(p.join(dir.path, 'ExpenseTracker', 'Exports'));
      if (!await exportDir.exists()) await exportDir.create(recursive: true);

      final fileName =
          'expenses_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      _logger.info('PDF exported to: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      _logger.error('Failed to export PDF', error: e, stackTrace: stackTrace);
      return null;
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
    _logger.info('Supabase service disposed');
  }
}
