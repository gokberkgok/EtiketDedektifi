import 'package:flutter/material.dart';

import '../constants/brand_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        BrandAssets.appIcon,
        width: size,
        height: size,
        cacheWidth: (size * pixelRatio).round(),
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Etiket Dedektifi logosu',
      ),
    );
  }
}
