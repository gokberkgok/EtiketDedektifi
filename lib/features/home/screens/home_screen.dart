import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../services/product_score.dart';
import '../../../state/app_scope.dart';
import '../../product/product_navigation.dart';
import '../../product/widgets/product_visuals.dart';
import '../../scanner/widgets/manual_barcode_sheet.dart';
import '../widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenHistory});

  final VoidCallback onOpenHistory;

  static const int _recentLimit = 4;

  Future<void> _typeBarcode(BuildContext context) async {
    final code = await showManualBarcodeSheet(context);
    if (code != null && context.mounted) {
      await ProductNavigation.openBarcode(context, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.history;
    final catalog = context.additives;

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final recent = history.records.take(_recentLimit).toList();
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
              const HomeHeader(),
              const SizedBox(height: AppSpacing.lg),
              ScanHeroCard(
                scansToday: history.countScannedOn(DateTime.now()),
                onScan: () => ProductNavigation.openScanner(context),
                onTypeBarcode: () => _typeBarcode(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Son taramalar',
                actionLabel: history.isEmpty ? null : 'Tümünü gör',
                onAction: onOpenHistory,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (recent.isEmpty)
                AppCard(
                  child: EmptyState(
                    compact: true,
                    icon: Icons.qr_code_2_rounded,
                    title: 'Henüz tarama yok',
                    message: 'İlk taradığın ürün hızlı erişim için burada görünecek.',
                    actionLabel: 'Ürün tara',
                    actionIcon: Icons.qr_code_scanner_rounded,
                    onAction: () => ProductNavigation.openScanner(context),
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Column(
                    children: [
                      for (var index = 0; index < recent.length; index++) ...[
                        if (index > 0)
                          const Divider(indent: 72, endIndent: AppSpacing.md),
                        ProductTile(
                          product: recent[index].product,
                          score: ProductScorer.evaluate(
                            recent[index].product,
                            catalog,
                          ),
                          caption: AppDateFormatter.relativeDateTime(
                            recent[index].scannedAt,
                          ),
                          onTap: () => ProductNavigation.openProduct(
                            context,
                            recent[index].product,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Etiketi okumak'),
              const SizedBox(height: AppSpacing.sm),
              const LabelGuideCard(),
            ],
          ),
        );
      },
    );
  }
}
