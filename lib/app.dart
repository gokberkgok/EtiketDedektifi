import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_dimens.dart';
import 'core/constants/brand_assets.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'navigation/bottom_navigation.dart';
import 'state/app_scope.dart';

class EtiketDedektifiApp extends StatefulWidget {
  const EtiketDedektifiApp({super.key});

  @override
  State<EtiketDedektifiApp> createState() => _EtiketDedektifiAppState();
}

class _EtiketDedektifiAppState extends State<EtiketDedektifiApp> {
  late Future<AppDependencies> _dependencies = _initialize();

  Future<AppDependencies> _initialize() {
    return AppDependencies.initialize(
      platformBrightness:
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  void _retry() => setState(() => _dependencies = _initialize());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _dependencies,
      builder: (context, snapshot) {
        final dependencies = snapshot.data;
        if (dependencies == null) {
          return _buildApp(
            themeMode: ThemeMode.system,
            home: snapshot.hasError
                ? _StartupErrorView(onRetry: _retry)
                : const _SplashView(),
          );
        }
        return AppScope(
          dependencies: dependencies,
          child: ListenableBuilder(
            listenable: dependencies.settings,
            builder: (context, _) => _buildApp(
              themeMode: dependencies.settings.themeType.themeMode,
              home: const AppShell(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApp({required ThemeMode themeMode, required Widget home}) {
    return MaterialApp(
      title: 'Etiket Dedektifi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: AppDurations.medium,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: home,
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumDark.background,
      body: Center(
        child: Image.asset(
          BrandAssets.splashMark,
          width: BrandAssets.splashMarkSize,
          height: BrandAssets.splashMarkSize,
          semanticLabel: 'Etiket Dedektifi yükleniyor',
        ),
      ),
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colors.negative,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Uygulama başlatılamadı',
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Yerel veriler hazırlanırken bir sorun oluştu. Lütfen tekrar dene.',
                style: textStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
