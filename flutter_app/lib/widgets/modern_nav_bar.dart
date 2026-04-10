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
    // Initial bounce if active
    _bounceControllers[widget.activeIndex].forward();
  }

  @override
  void didUpdateWidget(ModernNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: MridaColors.surface.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -12),
                blurRadius: 40,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_filled, 'HOME'),
              _buildNavItem(1, Icons.history, 'HISTORY'),
              _buildCenterFAB(2),
              _buildNavItem(3, Icons.map_outlined, 'MAP'),
              _buildNavItem(4, Icons.person_outline, 'PROFILE'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = widget.activeIndex == index;
    final color = isActive ? MridaColors.primary : MridaColors.primary.withOpacity(0.3);

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(
                  parent: _bounceControllers[index],
                  curve: const Interval(0.0, 0.5, curve: Curves.bounceOut),
                ),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: color,
              ),
              child: Text(label),
            ),
            // Active line indicator (matching React line width logic)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 6),
              width: isActive ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: MridaColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFAB(int index) {
    final isActive = widget.activeIndex == index;
    
    return InkWell(
      onTap: () => widget.onItemSelected(index),
      child: Transform.translate(
        offset: const Offset(0, -22),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: MridaColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: MridaColors.primary.withOpacity(0.25),
                offset: const Offset(0, 12),
                blurRadius: 24,
              ),
            ],
            border: Border.all(
              color: MridaColors.surface.withOpacity(0.5),
              width: 4,
            ),
          ),
          child: const Center(
            child: Icon(Icons.add_rounded, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }
}
