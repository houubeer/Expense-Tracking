import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:intl/intl.dart';

/// Owner/Super Admin Dashboard Screen
/// Displays platform-wide KPIs and pending manager approvals
class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  bool _isLoading = true;
  String? _error;

  // Stats
  int _totalCompanies = 0;
  int _totalUsers = 0; // employees + managers
  int _pendingCount = 0;

  // Recent activity
  List<Map<String, dynamic>> _recentOrganizations = [];

  // Pending managers list
  List<Map<String, dynamic>> _pendingManagers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      // Load pending organizations
      final pending = await supabaseService.getPendingOrganizations();
      final active = await supabaseService.getApprovedOrganizations();

      // Get total active employees + managers count
      final usersResponse = await supabaseService.client
          .from('user_profiles')
          .select('id, role, status')
          .or('role.eq.employee,role.eq.manager')
          .eq('status', 'active');
      final usersCount = usersResponse.length;

      setState(() {
        _pendingManagers = pending
            .map((org) => {
                  'id': org.id,
                  'name': org.managerName ?? 'Unknown',
                  'email': org.managerEmail,
                  'company': org.name,
                  'date': org.createdAt,
                })
            .toList();
        _totalCompanies = active.length; // approved status in DB
        _totalUsers = usersCount;
        _pendingCount = pending.length;
        _recentOrganizations = active.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(String orgId, String managerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Manager'),
        content: Text('Are you sure you want to approve $managerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.approveOrganization(orgId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(String orgId, String managerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Manager & Organization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete $managerName?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The organization and user account will be permanently deleted.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.deleteOrganizationAndManager(orgId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organization and manager deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Clear Hive session data
      final box = await Hive.openBox<dynamic>('auth_preferences');
      await box.clear();

      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.signOut();
      if (mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Top bar with logout
              _buildTopBar(),
              const SizedBox(height: AppSpacing.xl),

              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text('Error: $_error'))
                        : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Text(
          'Owner Dashboard',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        // Logout button
        ElevatedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Stats and Recent Activity
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat cards row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active Companies',
                        _totalCompanies.toString(),
                        Icons.business,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _buildStatCard(
                        'Total Users',
                        _totalUsers.toString(),
                        Icons.people,
                        AppColors.green,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _buildStatCard(
                        'Pending Approvals',
                        _pendingCount.toString(),
                        Icons.pending_actions,
                        AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Recent Organizations section
                _buildRecentOrganizationsSection(),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),

        // Right side - Pending requests floating card
        Expanded(
          flex: 2,
          child: _buildPendingRequestsCard(),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrganizationsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Organizations',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_recentOrganizations.length} active',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_recentOrganizations.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No active organizations yet',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentOrganizations.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final org = _recentOrganizations[index];
                return _buildOrganizationRow(org);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrganizationRow(Map<String, dynamic> org) {
    final createdAt = org['created_at'] != null
        ? DateTime.tryParse(org['created_at'].toString())
        : null;
    final formattedDate = createdAt != null
        ? DateFormat('MMM d, yyyy').format(createdAt)
        : 'Unknown';

    return Row(
      children: [
        // Company icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.business,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Company info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                org['name'] as String? ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                org['manager_email'] as String? ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Date
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            formattedDate,
            style: TextStyle(
              color: AppColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingRequestsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pending_actions,
                    color: AppColors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_pendingManagers.length} awaiting review',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table content
          Expanded(
            child: _pendingManagers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No pending requests',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All caught up!',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _pendingManagers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final manager = _pendingManagers[index];
                      return _buildManagerCard(manager);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerCard(Map<String, dynamic> manager) {
    final createdAt = manager['date'] != null
        ? DateTime.tryParse(manager['date'].toString())
        : null;
    final formattedDate = createdAt != null
        ? DateFormat('MMM d, yyyy').format(createdAt)
        : 'Unknown';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manager info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (manager['name'] as String? ?? 'U').isNotEmpty
                      ? (manager['name'] as String? ?? 'U')[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager['name'] as String? ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      manager['company'] as String? ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Email
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  manager['email'] as String? ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Date
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleDelete(
                    manager['id'] as String? ?? '',
                    manager['name'] as String? ?? 'Unknown',
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleApprove(
                    manager['id'] as String? ?? '',
                    manager['name'] as String? ?? 'Unknown',
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
