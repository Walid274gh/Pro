import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyState extends StatelessWidget {
	final String animationAsset;
	final String title;
	final String? subtitle;
	const EmptyState({super.key, required this.animationAsset, required this.title, this.subtitle});

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(24),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Lottie.asset(animationAsset, width: 220, repeat: true, errorBuilder: (_, __, ___) => const Icon(Icons.inbox, size: 96, color: Colors.black26)),
						const SizedBox(height: 12),
						Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
						if (subtitle != null) ...[
							const SizedBox(height: 6),
							Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54), textAlign: TextAlign.center),
						],
					],
				),
			),
		);
	}
}