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

/// This class can be used to create a new window.
class WindowStackController {
  WindowStackController(this._onUpdate);

  // List of windows.
  final List<Window> _windows = [];
  List<Window> get windows => _windows;

  final VoidCallback _onUpdate;

  Window createWindow() {
    Window window = Window._();
    Vector2 normalStatePos = Vector2.zero();
    Vector2 normalStateSize = Vector2.zero();
    WindowState previousState = WindowState.normal;

    // Init onFocusChanged.
    void onFocusChangedEvent(WindowEvent<bool>? val) {
      if (!val!.value) {
        return;
      }

      // Put on top of stack.
      _windows.remove(window);
      _windows.add(window);

      // Unfocus previous window.
      int index = _windows.length - 2;
      if (index >= 0 && index < _windows.length) _windows[index].setFocus(false);

      _onUpdate();
    }

    // Init onPosChanged.
    void onPosChangedEvent(WindowEvent<Vector2>? val) {
      _onUpdate();
    }

    // Init onSizeChanged.
    void onSizeChangedEvent(WindowEvent<Vector2>? val) {
      _onUpdate();
    }

    // Init onStateChanged.
    // NOTE: Events like setPos and setSize will be cancelled by preprocessors in [_WindowStackItemState]
    // while the state is changing. Because of this, we call _onUpdate() in the end of this function.
    void onStateChangedEvent(WindowEvent<WindowState>? val) {
      if (val!.value != WindowState.normal) {
        normalStatePos = window.pos;
        normalStateSize = window.size;
      }

      if (val.value == WindowState.normal) {
        if (previousState != WindowState.normal) {
          window.setPos(normalStatePos, true);
          window.setSize(normalStateSize, false, true);
        }
      } else if (val.value == WindowState.maximized) {
        window.setPos(Vector2.zero(), true);
        window.setSize(Vector2(double.infinity, double.infinity), false, true);
      } else if (val.value == WindowState.minimized) {
        if (previousState == WindowState.minimized) window.setState(WindowState.normal);
        window.setPos(Vector2(_windows.indexOf(window) * 100 + 10, 10), true);
        window.setSize(Window.defaultMinWindowSize, true, true);
      }

      previousState = val.value;
      _onUpdate();
    }

    // Subscribe to events
    window.onFocusChanged.subscribe(PrioritizedEventHandler(onFocusChangedEvent, EventPriority.lowest.value));
    window.onPosChanged.subscribe(PrioritizedEventHandler(onPosChangedEvent, EventPriority.lowest.value));
    window.onSizeChanged.subscribe(PrioritizedEventHandler(onSizeChangedEvent, EventPriority.lowest.value));
    window.onStateChanged.subscribe(PrioritizedEventHandler(onStateChangedEvent));

    // Close callback
    window._close = () {
      // Unsubscribe from events
      window.onFocusChanged.unsubscribe(onFocusChangedEvent);
      window.onPosChanged.unsubscribe(onPosChangedEvent);
      window.onPosChanged.unsubscribe(onSizeChangedEvent);
      window.onStateChanged.unsubscribe(onStateChangedEvent);

      // Remove window and rebuild widget tree.
      window._dispose();
      _windows.remove(window);
      _onUpdate();
    };

    // Add Window to List.
    _windows.add(window);
    window.setFocus(true);

    // Set initial position.
    //Random rng = Random();
    //window.setPos(Vector2(rng.nextDouble() * 500, rng.nextDouble() * 500));
    window.setPos(Vector2(0, 0));

    // Update Widgets after adding the new window.
    _onUpdate();
    return window;
  }
}
