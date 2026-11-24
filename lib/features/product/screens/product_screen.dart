import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ad_banner.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../models/product.dart';
import '../../../services/product_api_service.dart';
import '../../../services/product_score.dart';
import '../../../state/app_scope.dart';
import '../product_navigation.dart';
import '../widgets/product_sections.dart';
import '../widgets/verdict_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.barcode, this.initialProduct});

  final String barcode;
  final Product? initialProduct;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

enum _LoadState { loading, loaded, notFound, failed }

class _ProductScreenState extends State<ProductScreen> {
  _LoadState _state = _LoadState.loading;
  Product? _product;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProduct;
    if (initial != null) {
      _product = initial;
      _state = _LoadState.loaded;
    } else {
      _load();
    }
  }

  void _retry() {
    setState(() => _state = _LoadState.loading);
    _load();
  }

  Future<void> _load() async {
    try {
      final product = await context.api.lookup(widget.barcode);
      if (!mounted) return;
      if (product == null) {
        setState(() => _state = _LoadState.notFound);
        return;
      }
      setState(() {
        _product = product;
        _state = _LoadState.loaded;
      });
      await context.history.add(product);
    } on ProductApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _state = _LoadState.failed;
      });
    }
  }

  void _scanAnother() => ProductNavigation.replaceWithScanner(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xs,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Geri',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Etiket raporu',
                      style: context.textStyles.titleLarge,
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.qr_code_scanner_rounded,
                    tooltip: 'Başka ürün tara',
                    onPressed: _scanAnother,
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text('Etiket çözümleniyor…', style: context.textStyles.bodySmall),
            ],
          ),
        );
      case _LoadState.notFound:
        return SingleChildScrollView(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Ürün bulunamadı',
            message:
                '${widget.barcode} barkodu henüz açık veri tabanlarında yok.',
            actionLabel: 'Başka ürün tara',
            actionIcon: Icons.qr_code_scanner_rounded,
            onAction: _scanAnother,
          ),
        );
      case _LoadState.failed:
        return SingleChildScrollView(
          child: EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Ürün yüklenemedi',
            message: _errorMessage,
            actionLabel: 'Tekrar dene',
            actionIcon: Icons.refresh_rounded,
            onAction: _retry,
          ),
        );
      case _LoadState.loaded:
        return _ProductReport(product: _product!);
    }
  }
}

class _ProductReport extends StatelessWidget {
  const _ProductReport({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final catalog = context.additives;
    final score = ProductScorer.evaluate(product, catalog);
    final additives = catalog.resolveAll(product.additiveCodes);
    final hasNutrition =
        product.nutrientLevels.isNotEmpty ||
        product.nutrientsPer100g.isNotEmpty;

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xs,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      children: [
        VerdictCard(product: product, score: score),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader(title: 'Bu puan neden?'),
        const SizedBox(height: AppSpacing.sm),
        ScoreFactorsCard(score: score),
        const SizedBox(height: AppSpacing.md),
        RatingBadgesRow(product: product),
        if (hasNutrition) ...[
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Besin değerleri'),
          const SizedBox(height: AppSpacing.sm),
          NutritionCard(product: product),
        ],
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Katkı maddeleri',
          subtitle: additives.isEmpty
              ? null
              : 'Risk seviyeleri EFSA aşırı tüketim değerlendirmelerinden',
        ),
        const SizedBox(height: AppSpacing.sm),
        AdditivesCard(additives: additives),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Diyet ve alerjenler'),
        const SizedBox(height: AppSpacing.sm),
        DietCard(product: product),
        if (product.ingredientsText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'İçindekiler'),
          const SizedBox(height: AppSpacing.sm),
          IngredientsCard(text: product.ingredientsText),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Veri: ${product.source.label} (ODbL). Yalnızca bilgilendirme amaçlıdır, '
          'tıbbi tavsiye değildir.',
          textAlign: TextAlign.center,
          style: context.textStyles.labelSmall,
        ),
      ],
    );
  }
}
