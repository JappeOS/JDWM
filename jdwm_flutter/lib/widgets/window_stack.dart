//  jdwm_flutter, The Flutter UI library for the JDWM window manager.
//  Copyright (C) 2025  The JappeOS team.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as
//  published by the Free Software Foundation, either version 3 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

part of jdwm_flutter;

/// A widget to manage windows.
class WindowStack extends StatefulWidget {
  /// The controller to manage the window stack.
  final WindowStackController wmController;

  /// Padding to apply when `monitors` is null.
  final EdgeInsetsGeometry dynamicMonitorInsets;

  /// The list of monitors to use. If null, the widget will use a single "dynamic" monitor that fills the available space.
  final List<Monitor>? monitors;

  /// The index of the primary monitor in the `monitors` list. Defaults to 0.
  final int primaryMonitorIndex;

  /// Creates a [WindowStack] widget.
  const WindowStack({super.key, required this.wmController, this.dynamicMonitorInsets = EdgeInsets.zero, this.monitors, this.primaryMonitorIndex = 0});

  @override
  State<WindowStack> createState() => _WindowStackState();
}

class _WindowStackState extends State<WindowStack> {
  final GlobalKey<WindowNavigatorHandle> _navigatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.wmController.init(_navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = WindowNavigator(
      key: _navigatorKey,
      initialWindows: const [],
      monitors: widget.monitors,
      primaryMonitorId: widget.primaryMonitorIndex,
      showTopSnapBar: false,
    );

    if (widget.monitors != null) {
      return navigator;
    } else {
      return Padding(
        padding: widget.dynamicMonitorInsets,
        child: navigator,
      );
    }
  }
}
