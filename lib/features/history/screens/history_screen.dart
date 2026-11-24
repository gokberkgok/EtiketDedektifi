import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../services/product_score.dart';
import '../../../state/app_scope.dart';
import '../../product/product_navigation.dart';
import '../../product/widgets/product_visuals.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _clear(BuildContext context) async {
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
    final history = context.history;
    final catalog = context.additives;
    final colors = context.colors;

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final records = history.records;
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
              ScreenHeader(
                title: 'Geçmiş',
                subtitle: '${records.length} taranmış ürün',
                trailing: records.isEmpty
                    ? null
                    : CircleIconButton(
                        icon: Icons.delete_sweep_rounded,
                        tooltip: 'Geçmişi temizle',
                        iconColor: colors.negative,
                        onPressed: () => _clear(context),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (records.isEmpty)
                EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Henüz ürün taranmadı',
                  message: 'Taradığın ürünler burada saklanır, internetsiz de açabilirsin.',
                  actionLabel: 'Ürün tara',
                  actionIcon: Icons.qr_code_scanner_rounded,
                  onAction: () => ProductNavigation.openScanner(context),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var index = 0; index < records.length; index++) ...[
                        if (index > 0)
                          const Divider(indent: 72, endIndent: AppSpacing.md),
                        Dismissible(
                          key: ValueKey(records[index].product.code),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              history.remove(records[index].product.code),
                          background: Container(
                            color: colors.negative,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: colors.onStatus,
                            ),
                          ),
                          child: ProductTile(
                            product: records[index].product,
                            score: ProductScorer.evaluate(
                              records[index].product,
                              catalog,
                            ),
                            caption: AppDateFormatter.relativeDateTime(
                              records[index].scannedAt,
                            ),
                            onTap: () => ProductNavigation.openProduct(
                              context,
                              records[index].product,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
