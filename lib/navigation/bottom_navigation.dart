import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/compare/screens/compare_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/product/product_navigation.dart';
import '../features/settings/screens/settings_screen.dart';
import '../state/app_scope.dart';

enum AppTab {
  home(
    label: 'Ana Sayfa',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  history(
    label: 'Geçmiş',
    icon: Icons.history_outlined,
    activeIcon: Icons.history_rounded,
  ),
  compare(
    label: 'Karşılaştır',
    icon: Icons.compare_arrows_outlined,
    activeIcon: Icons.compare_arrows_rounded,
  ),
  settings(
    label: 'Ayarlar',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
  );

  const AppTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _currentTab = AppTab.home;
  late final Map<AppTab, Widget> _screens = {
    AppTab.home: HomeScreen(onOpenHistory: () => _selectTab(AppTab.history)),
    AppTab.history: const HistoryScreen(),
    AppTab.compare: const CompareScreen(),
    AppTab.settings: const SettingsScreen(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.ads.initialize();
    });
  }

  void _selectTab(AppTab tab) {
    if (tab == _currentTab) return;
    HapticFeedback.selectionClick();
    setState(() => _currentTab = tab);
  }

  void _openScanner() {
    HapticFeedback.lightImpact();
    ProductNavigation.openScanner(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyleFor(Theme.of(context).brightness),
      child: PopScope(
        canPop: _currentTab == AppTab.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _selectTab(AppTab.home);
        },
        child: Scaffold(
          backgroundColor: colors.background,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              for (final tab in AppTab.values)
                _TabPage(isActive: tab == _currentTab, child: _screens[tab]!),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 110 + MediaQuery.paddingOf(context).bottom,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.background.withValues(alpha: 0),
                          colors.background.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingNavigationBar(
                  currentTab: _currentTab,
                  onTabSelected: _selectTab,
                  onAddPressed: _openScanner,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: ExcludeSemantics(
        excluding: !isActive,
        child: AnimatedOpacity(
          opacity: isActive ? 1 : 0,
          duration: AppDurations.medium,
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: isActive ? Offset.zero : const Offset(0, 0.015),
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
            child: TickerMode(enabled: isActive, child: child),
          ),
        ),
      ),
    );
  }
}

class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onAddPressed;

  static const double _barHeight = 68;
  static const double _addButtonSize = 60;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    Widget item(AppTab tab) => Expanded(
      child: _NavigationItem(
        tab: tab,
        isActive: tab == currentTab,
        onTap: () => onTabSelected(tab),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        bottomInset + AppSpacing.sm,
      ),
      child: SizedBox(
        height: _barHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.navBackground,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: colors.overlayShadow,
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: AppSpacing.xxs),
                item(AppTab.home),
                item(AppTab.history),
                const SizedBox(width: _addButtonSize + AppSpacing.md),
                item(AppTab.compare),
                item(AppTab.settings),
                const SizedBox(width: AppSpacing.xxs),
              ],
            ),
            Positioned(
              top: -14,
              child: _AddButton(size: _addButtonSize, onPressed: onAddPressed),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final AppTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isActive,
      label: tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: Curves.easeOutCubic,
              width: isActive ? 46 : 34,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? colors.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 22,
                color: isActive ? colors.accent : colors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: context.textStyles.labelSmall!.copyWith(
                fontSize: 10.5,
                color: isActive ? colors.textPrimary : colors.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
              child: Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.size, required this.onPressed});

  final double size;
  final VoidCallback onPressed;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Barkod tara',
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1,
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: colors.background, width: 4),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              size: 28,
              color: colors.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}
