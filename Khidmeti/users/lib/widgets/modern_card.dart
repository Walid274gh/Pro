import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final BoxShadow? shadow;
  final VoidCallback? onTap;
  final bool enableAnimation;
  final Duration animationDuration;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
    this.onTap,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(20),
      margin: margin ?? EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? kSurfaceColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: [
          shadow ??
              BoxShadow(
                color: kPrimaryDark.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

// Variante avec animation de hover
class ModernHoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final BoxShadow? shadow;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const ModernHoverCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _ModernHoverCardState createState() => _ModernHoverCardState();
}

class _ModernHoverCardState extends State<ModernHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? EdgeInsets.all(20),
              margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? kSurfaceColor,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
                boxShadow: [
                  widget.shadow ??
                      BoxShadow(
                        color: kPrimaryDark.withOpacity(0.1),
                        blurRadius: _elevationAnimation.value,
                        offset: Offset(0, _elevationAnimation.value / 3),
                      ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Variante avec gradient
class ModernGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? gradientColors;
  final double? borderRadius;
  final BoxShadow? shadow;
  final VoidCallback? onTap;
  final bool enableAnimation;
  final Duration animationDuration;

  const ModernGradientCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.gradientColors,
    this.borderRadius,
    this.shadow,
    this.onTap,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(20),
      margin: margin ?? EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [kButtonGradient1, kButtonGradient2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: [
          shadow ??
              BoxShadow(
                color: kPrimaryDark.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    if (enableAnimation) {
      return AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

// Variante avec bordure animée
class ModernAnimatedBorderCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const ModernAnimatedBorderCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  _ModernAnimatedBorderCardState createState() => _ModernAnimatedBorderCardState();
}

class _ModernAnimatedBorderCardState extends State<ModernAnimatedBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: widget.padding ?? EdgeInsets.all(20),
          margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? kSurfaceColor,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
            border: Border.all(
              color: (widget.borderColor ?? kPrimaryTeal).withOpacity(_borderAnimation.value),
              width: widget.borderWidth ?? 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimaryDark.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}