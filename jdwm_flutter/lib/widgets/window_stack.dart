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
/*class WindowStack extends StatelessWidget {
  final WindowStackController wmController;
  final EdgeInsetsGeometry insets;

  const WindowStack({Key? key, required this.wmController, this.insets = EdgeInsets.zero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: insets, child: WindowNavigator(key: wmController._navigatorKey, initialWindows: const []));
  }
}*/

class WindowStack extends StatefulWidget {
  final WindowStackController wmController;
  final EdgeInsetsGeometry insets;

  const WindowStack({super.key, required this.wmController, this.insets = EdgeInsets.zero});

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
    return Padding(
      padding: widget.insets,
      child: WindowNavigator(
        key: _navigatorKey,
        initialWindows: const [],
      ),
    );
  }
}
