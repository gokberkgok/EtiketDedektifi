import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../state/app_scope.dart';
import '../widgets/theme_option_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Geçmişi temizle',
      message: 'Taranan tüm ürünler bu cihazdan silinecek.',
      confirmLabel: 'Temizle',
      icon: Icons.delete_sweep_rounded,
    );
    if (confirmed && context.mounted) {
      await context.history.clear();
      if (context.mounted) {
        AppFeedback.showSuccess(context, 'Geçmiş temizlendi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.settings;
    final history = context.history;
    final ads = context.ads;

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xs,
          AppSpacing.screen,
          AppSpacing.navigationClearance + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const ScreenHeader(
            title: 'Ayarlar',
            subtitle: 'Uygulamayı kendine göre ayarla',
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Görünüm'),
          const SizedBox(height: AppSpacing.sm),
          ListenableBuilder(
            listenable: settings,
            builder: (context, _) => Row(
              children: [
                for (final type in AppThemeType.values) ...[
                  if (type != AppThemeType.values.first)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ThemeOptionCard(
                      type: type,
                      isSelected: settings.themeType == type,
                      onTap: () => settings.setThemeType(type),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Gizlilik ve veriler'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                FutureBuilder<bool>(
                  future: ads.isPrivacyOptionsRequired(),
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox.shrink();
                    return Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Reklam gizlilik seçenekleri',
                          subtitle: 'Reklam onay tercihlerini gözden geçir',
                          onTap: ads.showPrivacyOptions,
                        ),
                        const Divider(indent: 68, endIndent: AppSpacing.md),
                      ],
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: history,
                  builder: (context, _) => _SettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    title: 'Tarama geçmişini temizle',
                    subtitle:
                        'Bu cihazda ${history.records.length} ürün saklanıyor',
                    isDestructive: true,
                    onTap: () => _clearHistory(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Hakkında'),
          const SizedBox(height: AppSpacing.sm),
          const _AboutCard(),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final tint = isDestructive ? colors.negative : colors.accent;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textStyles.titleSmall?.copyWith(
                      color: isDestructive ? colors.negative : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Etiket Dedektifi', style: textStyles.titleMedium),
                    Text('Sürüm 1.0.0', style: textStyles.labelSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ürün verileri Open Database License kapsamında Open Food Facts, '
            'Open Beauty Facts ve Open Products Facts kaynaklarından gelir. '
            'Katkı risk seviyeleri EFSA aşırı tüketim değerlendirmelerine dayanır. '
            'Sonuçlar bilgilendirme amaçlıdır, tıbbi tavsiye değildir.',
            style: textStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
