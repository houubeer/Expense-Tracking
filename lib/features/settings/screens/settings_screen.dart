import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/theme_provider.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/locale_provider.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/account_provider.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/notifications_provider.dart';
import 'package:expense_tracking_desktop_app/features/settings/widgets/backup_restore_content.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:expense_tracking_desktop_app/services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.person_outline_rounded, 'label': 'Account'},
    {'icon': Icons.description_outlined, 'label': 'Export Reports'},
    {'icon': Icons.palette_outlined, 'label': 'Appearance'},
    {'icon': Icons.language_outlined, 'label': 'Language'},
    {'icon': Icons.notifications_none_rounded, 'label': 'Notifications'},
    {'icon': Icons.security_outlined, 'label': 'Security'},
    {'icon': Icons.backup_outlined, 'label': 'Backup & Restore'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent, // Transparent to show backdrop
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              // Use a subtle translucent surface color so the backdrop isn't pure black
              child: Container(
                // Keep transparent-ish but tinted by the theme so underlying content
                // shows through with a slight tint and no harsh black. Use
                // onBackground so the tint contrasts the current theme instead
                // of always using surface (which can be dark).
                color: colorScheme.onSurface.withAlpha((0.06 * 255).round()),
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.85, // 85% of screen width
              height: MediaQuery.of(context).size.height *
                  0.85, // 85% of screen height
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.3 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.settings,
                                  style: AppTextStyles.heading2.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  AppLocalizations.of(context)!
                                      .manageAccountPreferences,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  // Try popping the root navigator first (dialog/modal pushed
                                  // to the root). If nothing to pop, fall back to navigating
                                  // home to ensure we don't throw "nothing to pop".
                                  final rootNav = Navigator.of(context,
                                      rootNavigator: true);
                                  if (rootNav.canPop()) {
                                    rootNav.pop();
                                  } else {
                                    context.go(AppRoutes.home);
                                  }
                                },
                                tooltip: MaterialLocalizations.of(context)
                                    .closeButtonTooltip,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Main Content Area
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Navigation Menu
                              SizedBox(
                                width: 250,
                                child: Card(
                                  elevation: 0,
                                  color: colorScheme.surfaceContainerHighest
                                      .withAlpha(50),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.md),
                                    child: ListView.separated(
                                      itemCount: _menuItems.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: AppSpacing.sm),
                                      itemBuilder: (context, index) {
                                        final item = _menuItems[index];
                                        final isSelected =
                                            _selectedIndex == index;
                                        return _SettingsMenuItem(
                                          icon: item['icon'] as IconData,
                                          label: item['label'] as String,
                                          isSelected: isSelected,
                                          onTap: () => setState(
                                            () => _selectedIndex = index,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xl),

                              // Right Content Area
                              Expanded(
                                child: Card(
                                  elevation: 0,
                                  color: colorScheme.surfaceContainerHighest
                                      .withAlpha(50),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.xl),
                                    child: _buildContent(_selectedIndex),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return const _AccountSettingsContent();
      case 1:
        return const _ExportReportsContent();
      case 2:
        return const _AppearanceContent();
      case 3:
        return const _LanguageContent();
      case 4:
        return const _NotificationsContent();
      case 5:
        return const _SecurityContent();
      case 6:
        return const BackupRestoreContent();
      default:
        return Center(
          child: Text(
            '${_menuItems[index]['label']} Settings coming soon',
            style: AppTextStyles.heading3,
          ),
        );
    }
  }
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountSettingsContent extends ConsumerStatefulWidget {
  const _AccountSettingsContent();

  @override
  ConsumerState<_AccountSettingsContent> createState() =>
      _AccountSettingsContentState();
}

class _AccountSettingsContentState
    extends ConsumerState<_AccountSettingsContent> {
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSaving = false;

  @override
  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleAvatarUpload(String userId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        final file = File(result.files.single.path!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading avatar...')),
          );
        }

        final url = await SupabaseService().uploadAvatar(file, userId);

        if (url != null) {
          final userProfile = ref.read(accountProvider).value;
          if (userProfile != null) {
            final updatedProfile = userProfile.copyWith(avatarUrl: url);
            final success =
                await SupabaseService().updateUserProfile(updatedProfile);

            if (success) {
              ref.invalidate(accountProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar updated successfully')),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Failed to update user profile')),
                );
              }
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating avatar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(accountProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => const Center(child: Text('Failed to load account')),
      data: (profile) {
        final displayName = profile?.fullName ?? profile?.email ?? '';
        final created = profile?.createdAt;
        final memberSince = created != null
            ? '${created.month}/${created.day}/${created.year}'
            : '';
        final location =
            (profile?.settings ?? {})['location'] as String? ?? '';

        // Initialize controllers if empty
        if (profile != null) {
          if (_fullNameController.text.isEmpty) {
            _fullNameController.text = profile.fullName ?? '';
          }
          if (_locationController.text.isEmpty) {
            _locationController.text = location == '' ? '' : location;
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.accountDetails,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.viewAndManagePersonalInfo,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Profile Header
              Row(
                children: [
                  Stack(
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => profile != null
                              ? _handleAvatarUpload(profile.id)
                              : null,
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            backgroundImage: profile?.avatarUrl != null
                                ? NetworkImage(profile!.avatarUrl!)
                                : null,
                            child: profile?.avatarUrl == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 36,
                                    color: colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppLocalizations.of(context)!.memberSince(memberSince),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.xl),

              // Editable Fields
              _buildEditableField(context,
                  AppLocalizations.of(context)!.fullName, _fullNameController),
              const SizedBox(height: AppSpacing.lg),
              _buildReadOnlyField(
                  context,
                  AppLocalizations.of(context)!.emailAddress,
                  profile?.email ?? '\u0014'),
              const SizedBox(height: AppSpacing.lg),
              _buildEditableField(context,
                  AppLocalizations.of(context)!.location, _locationController),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  FilledButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            final notifier = ref.read(accountProvider.notifier);
                            final okName = await notifier.updateFullName(
                                _fullNameController.text.trim());
                            final okLoc = await notifier.updateLocation(
                                _locationController.text.trim());
                            setState(() => _isSaving = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text((okName || okLoc)
                                      ? 'Account updated'
                                      : 'Failed to update account')),
                            );
                          },
                    child: Text(_isSaving
                        ? 'Saving...'
                        : AppLocalizations.of(context)!.saveChanges),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(70),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForLabel(label),
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(70),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(_getIconForLabel(label),
              size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      border: InputBorder.none, isDense: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Full Name':
        return Icons.person_outline;
      case 'Email Address':
        return Icons.email_outlined;
      case 'Location':
        return Icons.location_on_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

class _ExportReportsContent extends StatefulWidget {
  const _ExportReportsContent();

  @override
  State<_ExportReportsContent> createState() => _ExportReportsContentState();
}

class _ExportReportsContentState extends State<_ExportReportsContent> {
  String _selectedDateRange = 'All Time';
  String _selectedCategory = 'All Categories';
  bool _isExporting = false;
  bool _isExportingPdf = false;

  Future<void> _handleCsvExport() async {
    setState(() => _isExporting = true);
    final svc = SupabaseService();
    final path = await svc.exportExpensesAsCsv(
      dateRange: _selectedDateRange,
      categoryName: _selectedCategory,
    );
    setState(() => _isExporting = false);
    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV exported to: $path'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to export CSV'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handlePdfExport() async {
    setState(() => _isExportingPdf = true);
    final svc = SupabaseService();
    final path = await svc.exportExpensesAsPdf(
      dateRange: _selectedDateRange,
      categoryName: _selectedCategory,
      includeReceipts: true,
    );
    setState(() => _isExportingPdf = false);
    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported to: $path'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to export PDF'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Reports',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Download your expense data in CSV or PDF format',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Filter Options',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date Range Dropdown
          _buildDropdownLabel(
            context,
            'Date Range',
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildDropdown(
            context,
            value: _selectedDateRange,
            items: ['All Time', 'Last Month', 'Last 3 Months', 'Last Year'],
            onChanged: (value) => setState(() => _selectedDateRange = value!),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Category Dropdown
          _buildDropdownLabel(context, 'Category', Icons.filter_alt_outlined),
          const SizedBox(height: AppSpacing.xs),
          _buildDropdown(
            context,
            value: _selectedCategory,
            items: [
              'All Categories',
              'Food',
              'Transport',
              'Utilities',
              'Entertainment',
            ],
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Export Format',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),

          // CSV Export Card
          _buildExportCard(
            context,
            title: 'CSV Export',
            description:
                'Download data in spreadsheet format (Excel, Google Sheets)',
            icon: Icons.table_chart_outlined,
            iconColor: Colors.green,
            buttonText: _isExporting ? 'Exporting...' : 'Export as CSV',
            buttonColor: Colors.green,
            buttonIcon: Icons.download_outlined,
            onTap: () {
              if (_isExporting) return;
              _handleCsvExport();
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // PDF Export Card
          _buildExportCard(
            context,
            title: 'PDF Export',
            description: 'Download formatted report for printing or sharing',
            icon: Icons.picture_as_pdf_outlined,
            iconColor: Colors.red,
            buttonText: _isExportingPdf ? 'Exporting...' : 'Export as PDF',
            buttonColor: Colors.red,
            buttonIcon: Icons.download_outlined,
            onTap: () {
              if (_isExportingPdf) return;
              _handlePdfExport();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownLabel(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(70),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colorScheme.outline.withAlpha(50)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurface,
          ),
          style:
              AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
          dropdownColor: colorScheme.surfaceContainerHighest,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required Color buttonColor,
    required IconData buttonIcon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 36.0), // Align with title text
            child: Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            // Button container
            padding: const EdgeInsets.only(), // Reset padding
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(buttonIcon, size: 18, color: Colors.white),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceContent extends ConsumerWidget {
  const _AppearanceContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedTheme = ref.watch(themeProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Customize how the app looks on your device',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Theme Mode',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  mode: ThemeMode.light,
                  icon: Icons.wb_sunny_outlined,
                  title: 'Light',
                  subtitle: 'Bright and clear',
                  isSelected: selectedTheme == ThemeMode.light,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ThemeCard(
                  mode: ThemeMode.dark,
                  icon: Icons.nightlight_outlined,
                  title: 'Dark',
                  subtitle: 'Easy on the eyes',
                  isSelected: selectedTheme == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ThemeCard(
                  mode: ThemeMode.system,
                  icon: Icons.monitor_outlined,
                  title: 'System',
                  subtitle: 'Match device',
                  isSelected: selectedTheme == ThemeMode.system,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });
  final ThemeMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final borderColor = isSelected
        ? const Color(0xFF3B82F6)
        : colorScheme.outline.withAlpha(50);

    final contentColor =
        isSelected ? const Color(0xFF3B82F6) : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(30),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: contentColor,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: contentColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageContent extends StatefulWidget {
  const _LanguageContent();

  @override
  State<_LanguageContent> createState() => _LanguageContentState();
}

class _LanguageContentState extends State<_LanguageContent> {
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final currentLocale = ref.watch(localeProvider);
        final selectedLanguageCode = currentLocale.languageCode;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select your preferred language',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search languages...',
                  prefixIcon:
                      Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Languages List
              ..._languages.map(
                (lang) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LanguageCard(
                    nativeName: lang['nativeName']!,
                    englishName: lang['name']!,
                    isSelected: selectedLanguageCode == lang['code'],
                    onTap: () async {
                      await ref
                          .read(localeProvider.notifier)
                          .setLocale(lang['code']!);
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.nativeName,
    required this.englishName,
    required this.isSelected,
    required this.onTap,
  });
  final String nativeName;
  final String englishName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = isSelected
        ? const Color(0xFF3B82F6)
        : colorScheme.outline.withAlpha(50);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6).withAlpha(20)
                : colorScheme.surfaceContainerHighest.withAlpha(30),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nativeName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2), // Tiny spacing
                    Text(
                      englishName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? const Color(0xFF3B82F6).withAlpha(200)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Color(0xFF3B82F6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsContent extends ConsumerStatefulWidget {
  const _NotificationsContent();

  @override
  ConsumerState<_NotificationsContent> createState() =>
      _NotificationsContentState();
}

class _NotificationsContentState extends ConsumerState<_NotificationsContent> {
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();

  @override
  void dispose() {
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settingsAsync = ref.watch(notificationsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed to load notifications: $e')),
      data: (settings) {
        // Ensure controllers are initialized
        final quiet = (settings['quietHours'] as Map<String, dynamic>?) ?? {};
        final from = quiet['from'] as String? ?? '22:00';
        final to = quiet['to'] as String? ?? '08:00';
        if (_fromTimeController.text.isEmpty) _fromTimeController.text = from;
        if (_toTimeController.text.isEmpty) _toTimeController.text = to;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.xs),
              Text('Manage how you receive notifications',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xl),

              // Notification Channels
              Text('Notification Channels',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              _buildToggleTile(
                context,
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                icon: Icons.notifications_none_outlined,
                value: (settings['channels']?['push'] as bool?) ?? true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setChannel('push', val),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleTile(
                context,
                title: 'Email Notifications',
                subtitle: 'Receive updates via email',
                icon: Icons.mail_outline,
                value: (settings['channels']?['email'] as bool?) ?? true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setChannel('email', val),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Notification Types
              Text('Notification Types',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              _buildToggleTile(
                context,
                title: 'New Expense Added',
                subtitle: 'Get notified when a new expense is recorded',
                icon: Icons.attach_money,
                value: (settings['types']?['newExpenseAdded'] as bool?) ?? true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setType('newExpenseAdded', val),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleTile(
                context,
                title: 'Budget Updates',
                subtitle: 'Get notified about budget status changes',
                icon: Icons.trending_up,
                value: (settings['types']?['budgetUpdates'] as bool?) ?? true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setType('budgetUpdates', val),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleTile(
                context,
                title: 'Budget Limit Warnings',
                subtitle: 'Alert when approaching or exceeding budget limits',
                icon: Icons.warning_amber_rounded,
                value: (settings['types']?['budgetLimitWarnings'] as bool?) ??
                    true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setType('budgetLimitWarnings', val),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleTile(
                context,
                title: 'Weekly Summary',
                subtitle: 'Receive weekly expense summary reports',
                icon: Icons.notifications_none,
                value: (settings['types']?['weeklySummary'] as bool?) ?? true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setType('weeklySummary', val),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleTile(
                context,
                title: 'Monthly Reports',
                subtitle: 'Get detailed monthly financial reports',
                icon: Icons.notifications_none,
                value: (settings['types']?['monthlyReports'] as bool?) ?? true,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setType('monthlyReports', val),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Quiet Hours
              Text('Quiet Hours',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              _buildQuietHoursCard(context, settings),

              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  FilledButton(
                    onPressed: () async {
                      final ok =
                          await ref.read(notificationsProvider.notifier).save();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Notification settings saved'
                              : 'Failed to save settings')));
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF3B82F6), // Blue from design
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursCard(
      BuildContext context, Map<String, dynamic> settings) {
    final colorScheme = Theme.of(context).colorScheme;
    final quiet = (settings['quietHours'] as Map<String, dynamic>?) ?? {};
    final enabled = quiet['enabled'] as bool? ?? false;

    // Keep controllers updated when settings change
    if (_fromTimeController.text.isEmpty)
      _fromTimeController.text = (quiet['from'] as String?) ?? '22:00';
    if (_toTimeController.text.isEmpty)
      _toTimeController.text = (quiet['to'] as String?) ?? '08:00';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enable Quiet Hours',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('Mute notifications during specified times',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (val) => ref
                    .read(notificationsProvider.notifier)
                    .setQuietHours(
                        enabled: val,
                        from: _fromTimeController.text,
                        to: _toTimeController.text),
                activeThumbColor: const Color(0xFF3B82F6),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _fromTimeController,
                        onChanged: (v) => ref
                            .read(notificationsProvider.notifier)
                            .setQuietHours(
                                enabled: true,
                                from: v,
                                to: _toTimeController.text),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: colorScheme.outlineVariant),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('To',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _toTimeController,
                        onChanged: (v) => ref
                            .read(notificationsProvider.notifier)
                            .setQuietHours(
                                enabled: true,
                                from: _fromTimeController.text,
                                to: v),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: colorScheme.outlineVariant),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SecurityContent extends StatelessWidget {
  const _SecurityContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Manage your account security and privacy settings',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Password Channel
          Text(
            'Password',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionCard(
            context,
            icon: Icons.vpn_key_outlined,
            title: 'Change Password',
            subtitle: 'Last changed 30 days ago',
            actions: [
              FilledButton(
                onPressed: () => _handleChangePassword(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Text('Update Password'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Two-Factor Authentication
          Text(
            'Two-Factor Authentication',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionCard(
            context,
            icon: Icons.phone_android_outlined,
            title: 'Authenticator App',
            subtitle: 'Use an authenticator app for additional security',
            trailing: Switch(
              value: false,
              onChanged: (val) => _handleToggle2FA(context, val),
              activeThumbColor: const Color(0xFF3B82F6),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Text('Set Up 2FA'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Active Sessions
          Text(
            'Active Sessions',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSessionCard(
            context,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => _handleSignOutOtherSessions(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: const Text('Sign out all other sessions'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Delete All Data (Danger Zone)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: Colors.red.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Delete All Data',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Permanently delete all your expense data. This action cannot be undone.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => _handleDeleteAllData(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: const Text('Delete All Data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChangePassword(BuildContext context) async {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPassController,
                decoration:
                    const InputDecoration(labelText: 'Current password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter current password' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: newPassController,
                decoration: const InputDecoration(labelText: 'New password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmController,
                decoration:
                    const InputDecoration(labelText: 'Confirm password'),
                obscureText: true,
                validator: (v) => v != newPassController.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final currentPass = currentPassController.text;
    final newPass = newPassController.text;

    final email = SupabaseService().currentUser?.email;
    if (email == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No authenticated user found'),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // Re-authenticate by signing in with current credentials to verify the password
      final authResp = await SupabaseService().client.auth.signInWithPassword(
            email: email,
            password: currentPass,
          );

      if (authResp.user == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Current password is incorrect'),
              backgroundColor: Colors.red),
        );
        return;
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to verify current password'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final success = await SupabaseService().updatePassword(newPass);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success ? 'Password updated' : 'Failed to update password'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _handleToggle2FA(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Two-Factor Authentication setup is not available in this build')),
    );
  }

  Future<void> _handleSignOutOtherSessions(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Signing out other sessions is not supported from the client.')),
    );
  }

  Future<void> _handleDeleteAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data'),
        content: const Text(
            'This will permanently delete your expense data. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await SupabaseService().deleteAllUserData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'All your expense data was deleted'
              : 'Failed to delete data')),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData? icon,
    List<Widget>? actions,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (actions != null && actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: actions,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          _buildSessionItem(
            context,
            title: 'Chrome on Windows',
            subtitle: 'New York, USA • Active now',
            isCurrent: true,
            showDivider: true,
          ),
          _buildSessionItem(
            context,
            title: 'Safari on iPhone',
            subtitle: 'New York, USA • 2 hours ago',
            isCurrent: false,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isCurrent,
    required bool showDivider,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Green
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text('Revoke'),
                ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(50)),
      ],
    );
  }
}
