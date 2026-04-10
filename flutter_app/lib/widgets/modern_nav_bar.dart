import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ModernNavBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onItemSelected;

  const ModernNavBar({
    super.key,
    required this.activeIndex,
    required this.onItemSelected,
  });

  @override
  State<ModernNavBar> createState() => _ModernNavBarState();
}

class _ModernNavBarState extends State<ModernNavBar> with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    if (widget.activeIndex < 5) {
      _bounceControllers[widget.activeIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ModernNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex && widget.activeIndex < 5) {
      _bounceControllers[widget.activeIndex].forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: MridaColors.surface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      offset: const Offset(0, 10),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildNavItem(0, Icons.home_filled, 'HOME')),
                    Expanded(child: _buildNavItem(1, Icons.history, 'HISTORY')),
                    Expanded(child: _buildCenterItem(2)),
                    Expanded(child: _buildNavItem(3, Icons.map_outlined, 'MAP')),
                    Expanded(child: _buildNavItem(4, Icons.person_outline, 'PROFILE')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = widget.activeIndex == index;
    final color = isActive
        ? MridaColors.primary
        : MridaColors.primary.withValues(alpha: 0.3);

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(
                parent: _bounceControllers[index],
                curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Active indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 5 : 0,
            height: isActive ? 5 : 0,
            decoration: BoxDecoration(
              color: MridaColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Center "+" button — same level as other items, not elevated.
  Widget _buildCenterItem(int index) {
    return InkWell(
      onTap: () => widget.onItemSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MridaColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MridaColors.primary.withValues(alpha: 0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              'SCAN',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: MridaColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
