import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/organization.dart';
import 'package:expense_tracking_desktop_app/features/auth/widgets/organization_card.dart';

/// Owner dashboard for approving/rejecting organization requests
class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Organization> _pendingOrgs = [];
  List<Organization> _approvedOrgs = [];
  List<Organization> _rejectedOrgs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrganizations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      final pending = await supabaseService.getPendingOrganizations();
      final approved = await supabaseService.getApprovedOrganizations();
      final rejected = await supabaseService.getRejectedOrganizations();

      if (!mounted) return;
      setState(() {
        _pendingOrgs = pending;
        _approvedOrgs = approved.map(Organization.fromJson).toList();
        _rejectedOrgs = rejected.map(Organization.fromJson).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _approveOrganization(Organization org) async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.approveOrganization(org.id);
      await _loadOrganizations();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.msgOrgApproved(org.name)),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.errApproveOrg(e.toString())),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _rejectOrganization(Organization org) async {
    final reason = await _showRejectDialog(org);
    if (reason == null) return;

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.rejectOrganization(org.id);
      await _loadOrganizations();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.msgOrgRejected(org.name)),
          backgroundColor: AppColors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.errRejectOrg(e.toString())),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<String?> _showRejectDialog(Organization org) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(AppLocalizations.of(context)!.dialogTitleRejectOrg(org.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.labelRejectReason,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.hintRejectReason,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(AppLocalizations.of(context)!.actionReject,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleOrganizationManagement),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textInverse,
          unselectedLabelColor:
              AppColors.textInverse.withAlpha((0.7 * 255).round()),
          indicatorColor: AppColors.textInverse,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.tabPending),
                  if (_pendingOrgs.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingOrgs.length}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
                text:
                    '${AppLocalizations.of(context)!.tabApproved} (${_approvedOrgs.length})'),
            Tab(
                text:
                    '${AppLocalizations.of(context)!.tabRejected} (${_rejectedOrgs.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrganizations,
            tooltip: AppLocalizations.of(context)!.actionRefresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrganizationList(_pendingOrgs, showActions: true),
                    _buildOrganizationList(_approvedOrgs),
                    _buildOrganizationList(_rejectedOrgs, showReason: true),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.red),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppLocalizations.of(context)!.errLoadOrgs,
            style:
                AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: _loadOrganizations,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.actionRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationList(
    List<Organization> organizations, {
    bool showActions = false,
    bool showReason = false,
  }) {
    if (organizations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context)!.msgNoOrgs,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrganizations,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          final org = organizations[index];
          return OrganizationCard(
            organization: org,
            showActions: showActions,
            showReason: showReason,
            onApprove: showActions ? () => _approveOrganization(org) : null,
            onReject: showActions ? () => _rejectOrganization(org) : null,
          );
        },
      ),
    );
  }
}
