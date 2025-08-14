import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class GradientCard extends StatelessWidget {
	final Widget child;
	final Gradient gradient;
	final EdgeInsetsGeometry padding;
	const GradientCard({super.key, required this.child, this.gradient = AppGradients.primary, this.padding = const EdgeInsets.all(16)});

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				gradient: gradient,
				borderRadius: BorderRadius.circular(20),
				boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
			),
			child: Container(
				padding: padding,
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(20),
					color: Colors.white.withOpacity(0.15),
					backgroundBlendMode: BlendMode.overlay,
				),
				child: child,
			),
		);
	}
}