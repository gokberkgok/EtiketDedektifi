import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../models/product.dart';
import '../../../services/ads/ad_service.dart';
import '../../../services/product_score.dart';
import '../../../state/app_scope.dart';
import '../../product/product_navigation.dart';
import '../../product/widgets/product_visuals.dart';
import '../widgets/comparison_table.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Product? _first;
  Product? _second;
  bool _isUnlocked = false;
  bool _isUnlocking = false;

  bool get _canCompare =>
      _first != null && _second != null && _first!.code != _second!.code;

  Future<void> _pick(bool isFirst) async {
    final picked = await showAppBottomSheet<Product>(
      context,
      builder: (_) =>
          _ProductPickerSheet(excludedCode: (isFirst ? _second : _first)?.code),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFirst) {
        _first = picked;
      } else {
        _second = picked;
      }
    });
  }

  Future<void> _unlock() async {
    final ads = context.ads;
    if (!ads.hasRewardedInterstitial) {
      setState(() => _isUnlocked = true);
      return;
    }
    final wantsAd = await showAppBottomSheet<bool>(
      context,
      builder: (_) => const _UnlockSheet(),
    );
    if (wantsAd != true || !mounted) return;
    setState(() => _isUnlocking = true);
    final outcome = await ads.showRewardedInterstitial();
    if (!mounted) return;
    setState(() {
      _isUnlocking = false;
      _isUnlocked = outcome != RewardOutcome.skipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.history;
    final catalog = context.additives;

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final hasEnough = history.records.length >= 2;
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
              AppSpacing.navigationClearance +
                  MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              const ScreenHeader(
                title: 'Karşılaştır',
                subtitle: 'Hangisi sepete girmeli?',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!hasEnough)
                EmptyState(
                  icon: Icons.compare_arrows_rounded,
                  title: 'Önce iki ürün tara',
                  message: 'Geçmişindeki iki ürünü yan yana karşılaştır.',
                  actionLabel: 'Ürün tara',
                  actionIcon: Icons.qr_code_scanner_rounded,
                  onAction: () => ProductNavigation.openScanner(context),
                )
              else ...[
                _SlotCard(
                  label: 'Ürün A',
                  product: _first,
                  onTap: () => _pick(true),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SlotCard(
                  label: 'Ürün B',
                  product: _second,
                  onTap: () => _pick(false),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_canCompare && _isUnlocked)
                  ComparisonTable(
                    first: _first!,
                    second: _second!,
                    firstScore: ProductScorer.evaluate(_first!, catalog),
                    secondScore: ProductScorer.evaluate(_second!, catalog),
                    firstFlagged: _flaggedCount(_first!),
                    secondFlagged: _flaggedCount(_second!),
                  )
                else
                  PrimaryButton(
                    label: 'Karşılaştır',
                    icon: Icons.compare_arrows_rounded,
                    isLoading: _isUnlocking,
                    onPressed: _canCompare ? _unlock : null,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  int _flaggedCount(Product product) => context.additives
      .resolveAll(product.additiveCodes)
      .where((additive) => additive.risk.weight > 0)
      .length;
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.label,
    required this.product,
    required this.onTap,
  });

  final String label;
  final Product? product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final selected = product;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Row(
        children: [
          selected == null
              ? Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.add_rounded, color: colors.accent),
                )
              : ProductThumb(imageUrl: selected.imageUrl, size: 46),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textStyles.labelSmall),
                const SizedBox(height: 2),
                Text(
                  selected?.displayName ?? 'Geçmişten seç',
                  style: textStyles.titleSmall?.copyWith(
                    color: selected == null ? colors.textMuted : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.swap_vert_rounded, color: colors.textMuted),
        ],
      ),
    );
  }
}

class _ProductPickerSheet extends StatelessWidget {
  const _ProductPickerSheet({required this.excludedCode});

  final String? excludedCode;

  @override
  Widget build(BuildContext context) {
    final catalog = context.additives;
    final records = context.history.records
        .where((record) => record.product.code != excludedCode)
        .toList();

    return AppBottomSheet(
      title: 'Bir ürün seç',
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < records.length; index++) ...[
              if (index > 0)
                const Divider(indent: 72, endIndent: AppSpacing.md),
              ProductTile(
                product: records[index].product,
                score: ProductScorer.evaluate(records[index].product, catalog),
                onTap: () => Navigator.of(context).pop(records[index].product),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnlockSheet extends StatelessWidget {
  const _UnlockSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return AppBottomSheet(
      title: 'Karşılaştırmayı aç',
      child: Column(
        children: [
          Icon(Icons.play_circle_fill_rounded, size: 48, color: colors.accent),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Yan yana karşılaştırmayı görmek için kısa bir reklam izle. '
            'Böylece Etiket Dedektifi ücretsiz kalır.',
            textAlign: TextAlign.center,
            style: textStyles.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Reklamı izle',
            icon: Icons.play_arrow_rounded,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Şimdi değil'),
          ),
        ],
      ),
    );
  }
}
