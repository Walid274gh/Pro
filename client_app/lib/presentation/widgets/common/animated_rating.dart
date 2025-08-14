import 'package:flutter/material.dart';

class AnimatedRating extends StatefulWidget {
	final double rating; // 0..5
	final double size;
	const AnimatedRating({super.key, required this.rating, this.size = 18});

	@override
	State<AnimatedRating> createState() => _AnimatedRatingState();
}

class _AnimatedRatingState extends State<AnimatedRating> with SingleTickerProviderStateMixin {
	late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final full = widget.rating.floor();
		final half = (widget.rating - full) >= 0.5;
		return Row(
			mainAxisSize: MainAxisSize.min,
			children: List.generate(5, (i) {
				IconData icon;
				if (i < full) {
					icon = Icons.star_rounded;
				} else if (i == full && half) {
					icon = Icons.star_half_rounded;
				} else {
					icon = Icons.star_border_rounded;
				}
				return ScaleTransition(
					scale: CurvedAnimation(parent: _controller, curve: Interval(i * 0.12, 1.0, curve: Curves.easeOutBack)),
					child: Icon(icon, size: widget.size, color: Colors.amber.shade600),
				);
			}),
		);
	}
}