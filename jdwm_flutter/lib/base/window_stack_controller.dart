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

/// Controller to manage the window stack.
class WindowStackController {
  late final GlobalKey<WindowNavigatorHandle> _navigatorKey;
  bool _initialized = false;
  final List<Window> _windows = [];

  /// Creates a [WindowStackController].
  WindowStackController();

  /// List of windows.
  List<Window> get windows => _navigatorKey.currentState != null
      ? _navigatorKey.currentState!.windows
      : [];

  /// Initializes the controller with the given navigator key.
  void init(GlobalKey<WindowNavigatorHandle> navigatorKey) {
    if (_initialized) return;
    _navigatorKey = navigatorKey;
    _initialized = true;
  }

  /// Creates a new window and adds it to the stack.
  void createWindow() {
    final window = Window(
      bounds: const Rect.fromLTWH(0, 0, 200, 200),
      title: Text(
          'Window ${_navigatorKey.currentState!.windows.length + 1}'),
      content: const Text("Hello World"),
    );
    _navigatorKey.currentState?.pushWindow(window);
    _windows.add(window);
  }
}