import 'package:flutter/material.dart';

class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({
    required this.title,
    required this.destinations,
    required this.body,
    super.key,
  });

  final String title;
  final List<NavigationDestination> destinations;
  final Widget body;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final medium = constraints.maxWidth >= 600;

        if (wide) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) {
                    setState(() => index = value);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final destination in widget.destinations)
                      NavigationRailDestination(
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.body),
              ],
            ),
          );
        }

        if (medium) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) {
                    setState(() => index = value);
                  },
                  labelType: NavigationRailLabelType.selected,
                  destinations: [
                    for (final destination in widget.destinations)
                      NavigationRailDestination(
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.body),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: widget.body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) {
              setState(() => index = value);
            },
            destinations: widget.destinations,
          ),
        );
      },
    );
  }
}
