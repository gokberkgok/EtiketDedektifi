import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

enum RewardOutcome { earned, skipped, unavailable }

class AdService extends ChangeNotifier {
  bool _isReady = false;
  bool _isLoadingRewarded = false;
  RewardedInterstitialAd? _rewardedInterstitial;

  bool get isReady => _isReady;

  bool get hasRewardedInterstitial => _rewardedInterstitial != null;

  Future<void> initialize() async {
    if (!AdConfig.isSupportedPlatform || _isReady) return;
    await _gatherConsent();
    await _startIfAllowed();
  }

  Future<bool> isPrivacyOptionsRequired() async {
    if (!AdConfig.isSupportedPlatform) return false;
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) => completer.complete());
    await completer.future;
    await _startIfAllowed();
  }

  Future<RewardOutcome> showRewardedInterstitial() async {
    final ad = _rewardedInterstitial;
    if (ad == null) {
      preloadRewardedInterstitial();
      return RewardOutcome.unavailable;
    }
    _rewardedInterstitial = null;
    notifyListeners();

    final result = Completer<RewardOutcome>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!result.isCompleted) {
          result.complete(
            earnedReward ? RewardOutcome.earned : RewardOutcome.skipped,
          );
        }
        preloadRewardedInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!result.isCompleted) result.complete(RewardOutcome.unavailable);
        preloadRewardedInterstitial();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earnedReward = true);
    return result.future;
  }

  void preloadRewardedInterstitial() {
    if (!_isReady || _rewardedInterstitial != null || _isLoadingRewarded) {
      return;
    }
    _isLoadingRewarded = true;
    RewardedInterstitialAd.load(
      adUnitId: AdConfig.rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingRewarded = false;
          _rewardedInterstitial = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) => _isLoadingRewarded = false,
      ),
    );
  }

  Future<void> _gatherConsent() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired(
        (_) => completer.complete(),
      ),
      (_) => completer.complete(),
    );
    return completer.future;
  }

  Future<void> _startIfAllowed() async {
    if (_isReady) return;
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    _isReady = true;
    notifyListeners();
    preloadRewardedInterstitial();
  }

  @override
  void dispose() {
    _rewardedInterstitial?.dispose();
    super.dispose();
  }
}
