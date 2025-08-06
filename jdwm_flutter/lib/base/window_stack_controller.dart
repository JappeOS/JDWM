//  jdwm_flutter, The Flutter UI library for the JDWM window manager.
//  Copyright (C) 2024  The JappeOS team.
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

class WindowStackController {
  final GlobalKey<WindowNavigatorHandle> navigatorKey;

  WindowStackController({required this.navigatorKey});

  // List of windows.
  final List<WindowController> _windows = [];
  List<WindowController> get windows => _windows;

  WindowController createWindow() {
    final controller = WindowController(bounds: const Rect.fromLTWH(0, 0, 300, 300));
    navigatorKey.currentState?.pushWindow(Window.controlled(controller: controller));
    _windows.add(controller);
    return controller;
  }
}