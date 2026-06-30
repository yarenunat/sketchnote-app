import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../settings/viewmodels/settings_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/app_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: isDark ? AppColors.darkPrimary : AppColors.inkBlack,
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Input ───────────────────────────────────────────────────────
          _SectionHeader(title: 'Input'),
          const SizedBox(height: 12),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Icons.back_hand_outlined,
              title: 'Left-handed Mode',
              subtitle: 'Mirrors the toolbar to the right side',
              value: settings.isLeftHandedMode,
              onChanged: (_) => vm.toggleHandedness(),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Apple Pencil / Stylus ────────────────────────────────────────
          _SectionHeader(title: 'Stylus'),
          const SizedBox(height: 12),
          _SettingsCard(children: [
            _ListTileItem(
              icon: Icons.touch_app_outlined,
              title: 'Double-tap Action',
              subtitle: _doubleTapLabel(settings.doubleTapAction),
              onTap: () => _showDoubleTapPicker(context, ref),
            ),
          ]),

          const SizedBox(height: 20),

          // ── Appearance ──────────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 12),
          _SettingsCard(children: [
            _ListTileItem(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Follows system setting',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // ── Storage ─────────────────────────────────────────────────────
          _SectionHeader(title: 'Storage & Export'),
          const SizedBox(height: 12),
          _SettingsCard(children: [
            _ListTileItem(
              icon: Icons.folder_outlined,
              title: 'Export Location',
              subtitle: 'Documents / SketchNote',
              onTap: () {},
            ),
            _CardDivider(),
            _ListTileItem(
              icon: Icons.cleaning_services_outlined,
              title: 'Clear Cache',
              subtitle: 'Frees up storage used by thumbnails',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          // ── About ────────────────────────────────────────────────────────
          _SectionHeader(title: 'About'),
          const SizedBox(height: 12),
          _SettingsCard(children: [
            _ListTileItem(
              icon: Icons.info_outline,
              title: 'SketchNote',
              subtitle: 'Version 0.1.0',
              onTap: () {},
            ),
            _CardDivider(),
            _ListTileItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _CardDivider(),
            _ListTileItem(
              icon: Icons.description_outlined,
              title: 'Open Source Licenses',
              onTap: () => showLicensePage(context: context),
            ),
          ]),

          const SizedBox(height: 32),

          // ── App signature ─────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SketchNote',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkPrimary : AppColors.inkBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional Digital Sketchbook',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _doubleTapLabel(PencilDoubleTapAction action) {
    switch (action) {
      case PencilDoubleTapAction.switchToEraser:
        return 'Switch to Eraser';
      case PencilDoubleTapAction.undo:
        return 'Undo';
      case PencilDoubleTapAction.showColorPicker:
        return 'Show Color Picker';
      case PencilDoubleTapAction.none:
        return 'None';
    }
  }

  void _showDoubleTapPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.warmGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Apple Pencil Double-Tap',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            for (final action in PencilDoubleTapAction.values)
              ListTile(
                title: Text(_doubleTapLabel(action)),
                trailing: ref.read(settingsViewModelProvider).doubleTapAction == action
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () {
                  ref
                      .read(settingsViewModelProvider.notifier)
                      .setDoubleTapAction(action);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        letterSpacing: 1.2,
        color: context.isDark ? AppColors.darkMuted : AppColors.warmGray500,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.warmGray100,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: context.textTheme.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: context.textTheme.bodySmall)
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.accent,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  const _ListTileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 22),
      title: Text(title, style: context.textTheme.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: context.textTheme.bodySmall)
          : null,
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      color: context.isDark ? AppColors.darkBorder : AppColors.warmGray100,
    );
  }
}
