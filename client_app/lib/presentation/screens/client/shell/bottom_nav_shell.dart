import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../jobs/my_jobs_screen.dart';

class BottomNavShell extends StatefulWidget {
	const BottomNavShell({super.key});

	@override
	State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
	int _index = 0;
	final List<Widget> _screens = const [ClientHomeScreen(), ClientMapScreen(), MyJobsScreen()];
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: _screens[_index],
			bottomNavigationBar: NavigationBar(
				selectedIndex: _index,
				onDestinationSelected: (i) => setState(() => _index = i),
				destinations: const [
					NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
					NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Carte'),
					NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Mes Travaux'),
				],
			),
		);
	}
}