import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/wheel_motif.dart';
import '../../../state/app_scope.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static String greetingFor(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return 'Günaydın';
    if (hour >= 12 && hour < 18) return 'İyi günler';
    if (hour >= 18 && hour < 23) return 'İyi akşamlar';
    return 'İyi geceler';
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final settings = context.settings;

    return Row(
      children: [
        const AppLogo(size: 44),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greetingFor(DateTime.now()), style: textStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                'Etiket Dedektifi',
                style: textStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            final isDark = settings.themeType == AppThemeType.premiumDark;
            return CircleIconButton(
              tooltip: isDark ? 'Açık temaya geç' : 'Koyu temaya geç',
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              onPressed: settings.toggleTheme,
            );
          },
        ),
      ],
    );
  }
}

class ScanHeroCard extends StatelessWidget {
  const ScanHeroCard({
    super.key,
    required this.scansToday,
    required this.onScan,
    required this.onTypeBarcode,
  });

  final int scansToday;
  final VoidCallback onScan;
  final VoidCallback onTypeBarcode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.heroStart, colors.heroEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.heroEnd.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -48,
            child: WheelMotif(
              size: 180,
              color: colors.heroForeground.withValues(alpha: 0.1),
              strokeWidth: 1.6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.heroForeground,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    scansToday == 0
                        ? 'Taramaya hazır'
                        : 'Bugün $scansToday ürün taradın',
                    style: textStyles.labelMedium?.copyWith(
                      color: colors.heroStart,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'İçinde gerçekten ne var?',
                  style: textStyles.headlineSmall?.copyWith(
                    color: colors.heroForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Barkodu okut; katkıları, şekeri ve tuzu saniyeler içinde gör.',
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.heroMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onScan,
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Ürün tara'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.heroForeground,
                          foregroundColor: colors.heroStart,
                          minimumSize: const Size.fromHeight(50),
                          textStyle: textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Material(
                      color: colors.heroForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: onTypeBarcode,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Tooltip(
                            message: 'Barkodu yaz',
                            child: Icon(
                              Icons.dialpad_rounded,
                              color: colors.heroForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LabelGuideCard extends StatelessWidget {
  const LabelGuideCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        children: [
          _GuideRow(
            icon: Icons.grade_rounded,
            color: colors.positive,
            title: 'Nutri-Score A–E',
            message: 'Genel besin kalitesi. En iyisi A.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _GuideRow(
            icon: Icons.factory_rounded,
            color: colors.caution,
            title: 'NOVA 1–4',
            message: 'Gıdanın ne kadar işlendiği. 4 ultra işlenmiş.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _GuideRow(
            icon: Icons.science_rounded,
            color: colors.negative,
            title: 'E-kodları',
            message: "EFSA'nın aşırı tüketim riski için işaretlediği katkılar.",
          ),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textStyles.titleSmall),
              Text(message, style: textStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
