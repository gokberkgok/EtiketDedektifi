import 'dart:io';

abstract final class AdConfig {
  static const String _androidBannerTest =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2435281174';
  static const String _androidRewardedInterstitialTest =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _iosRewardedInterstitialTest =
      'ca-app-pub-3940256099942544/6978759866';

  static const String _androidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER',
    defaultValue: _androidBannerTest,
  );
  static const String _iosBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER',
    defaultValue: _iosBannerTest,
  );
  static const String _androidRewardedInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_INTERSTITIAL',
    defaultValue: _androidRewardedInterstitialTest,
  );
  static const String _iosRewardedInterstitial = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_INTERSTITIAL',
    defaultValue: _iosRewardedInterstitialTest,
  );

  static bool get isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  static String get bannerUnitId =>
      Platform.isIOS ? _iosBanner : _androidBanner;

  static String get rewardedInterstitialUnitId =>
      Platform.isIOS ? _iosRewardedInterstitial : _androidRewardedInterstitial;
}
