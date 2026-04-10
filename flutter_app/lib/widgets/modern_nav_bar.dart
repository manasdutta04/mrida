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
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: BoxDecoration(
            color: MridaColors.surface.withOpacity(0.12),
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
            children: [
              Expanded(child: _buildNavItem(0, Icons.home_filled, 'HOME')),
              Expanded(child: _buildNavItem(1, Icons.history, 'HISTORY')),
              Expanded(child: _buildCenterFAB(2)),
              Expanded(child: _buildNavItem(3, Icons.map_outlined, 'MAP')),
              Expanded(child: _buildNavItem(4, Icons.person_outline, 'PROFILE')),
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
          const SizedBox(height: 6),
          // Precise active indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 12 : 0,
            height: 2.5,
            decoration: BoxDecoration(
              color: MridaColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterFAB(int index) {
    return InkWell(
      onTap: () => widget.onItemSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -26),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MridaColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MridaColors.primary.withOpacity(0.3),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
              border: Border.all(
                color: MridaColors.surface.withOpacity(0.6),
                width: 3,
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
