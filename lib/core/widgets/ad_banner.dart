import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/ads/ad_config.dart';
import '../../state/app_scope.dart';
import '../theme/app_colors.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _isLoaded = false;
  bool _isRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfPossible();
  }

  Future<void> _loadIfPossible() async {
    if (_isRequested || !context.ads.isReady) return;
    _isRequested = true;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
          Orientation.portrait,
          width,
        );
    if (!mounted || size == null) return;
    final banner = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _banner = null);
        },
      ),
    );
    setState(() => _banner = banner);
    await banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    return ListenableBuilder(
      listenable: context.ads,
      builder: (context, _) {
        if (!_isRequested && context.ads.isReady) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _loadIfPossible(),
          );
        }
        if (banner == null || !_isLoaded) return const SizedBox.shrink();
        return ColoredBox(
          color: context.colors.background,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: banner.size.width.toDouble(),
              height: banner.size.height.toDouble(),
              child: AdWidget(ad: banner),
            ),
          ),
        );
      },
    );
  }
}
