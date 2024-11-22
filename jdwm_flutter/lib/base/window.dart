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

/// Represents an application-instantiated window that can be rendered to.
class Window {
  static final defaultMinWindowSize = Vector2(107, 37);

  Window._() {
    onTitleChanged.subscribe((args) => onEvent.broadcast(args));
    onFocusChanged.subscribe((args) => onEvent.broadcast(args));
    onResizableChanged.subscribe((args) => onEvent.broadcast(args));
    onBackgroundRenderModeChanged.subscribe((args) => onEvent.broadcast(args));
    onPosChanged.subscribe((args) => onEvent.broadcast(args));
    onSizeChanged.subscribe((args) => onEvent.broadcast(args));
    onMinSizeChanged.subscribe((args) => onEvent.broadcast(args));
    onStateChanged.subscribe((args) => onEvent.broadcast(args));
    onNewRender.subscribe((args) => onEvent.broadcast(args));
  }

  void _dispose() {
    onTitleChanged.unsubscribeAll();
    onFocusChanged.unsubscribeAll();
    onResizableChanged.unsubscribeAll();
    onBackgroundRenderModeChanged.unsubscribeAll();
    onPosChanged.unsubscribeAll();
    onSizeChanged.unsubscribeAll();
    onMinSizeChanged.unsubscribeAll();
    onStateChanged.unsubscribeAll();
    onNewRender.unsubscribeAll();

    onEvent.unsubscribeAll();
    _eventPreprocessors.clear();
  }

  final Key key = UniqueKey();

  // Variable store and getters

  String _title = "";
  String get title => _title;

  bool _isFocused = false;
  bool get isFocused => _isFocused;

  bool _isResizable = false;
  bool get isResizable => _isResizable;

  BackgroundMode _bgRenderMode = BackgroundMode.normal;
  BackgroundMode get bgRenderMode => _bgRenderMode;

  Vector2 _pos = Vector2.zero();
  Vector2 get pos => _pos;

  Vector2 _size = defaultMinWindowSize;
  Vector2 get size => _size;

  Vector2 _minSize = defaultMinWindowSize;
  Vector2 get minSize => _minSize;

  WindowState _state = WindowState.normal;
  WindowState get state => _state;

  Uint8List? _render;
  Uint8List? get render => _render;

  // Controller callbacks

  late Function() _close;

  // Functions

  void setTitle(String title) {
    _title = title;
    _broadcastEvent(onTitleChanged, WindowEvent._("onTitleChanged", this.title));
  }

  void setFocus(bool hasFocus) {
    _isFocused = hasFocus;
    _broadcastEvent(onFocusChanged, WindowEvent._("onFocusChanged", isFocused));
  }

  void setResizable(bool isResizable) {
    _isResizable = isResizable;
    _broadcastEvent(onResizableChanged, WindowEvent._("onResizableChanged", this.isResizable));
  }

  void setBgRenderMode(BackgroundMode mode) {
    _bgRenderMode = mode;
    _broadcastEvent(onBackgroundRenderModeChanged, WindowEvent._("onBackgroundRenderModeChanged", bgRenderMode));
  }

  void setPos(Vector2 pos, [bool forceIgnoreState = false]) {
    if (!forceIgnoreState) setState(WindowState.normal);
    _pos = pos;
    _broadcastEvent(onPosChanged, WindowEvent._("onPosChanged", this.pos));
  }

  void setSize(Vector2 size, [bool forceSetSize = false, bool forceIgnoreState = false]) {
    if (!isResizable && !forceSetSize) return;
    if (!forceIgnoreState) setState(WindowState.normal);

    double x = size.x;
    double y = size.y;

    if (!forceSetSize) {
      if (x < minSize.x) {
        x = minSize.x;
      }

      if (y < minSize.y) {
        y = minSize.y;
      }
    }

    _size = Vector2(x, y);
    _broadcastEvent(onSizeChanged, WindowEvent._("onSizeChanged", this.size));
  }

  void setMinSize(Vector2 size) {
    double x = size.x;
    double y = size.y;

    if (x < defaultMinWindowSize.x) {
      x = defaultMinWindowSize.x;
    }

    if (y < defaultMinWindowSize.y) {
      y = defaultMinWindowSize.y;
    }

    _minSize = Vector2(x, y);
    _broadcastEvent(onMinSizeChanged, WindowEvent._("onMinSizeChanged", minSize));
  }

  void setState(WindowState state) {
    _state = state;
    _broadcastEvent(onStateChanged, WindowEvent._("onStateChanged", this.state));
  }

  void setRender(Uint8List tex) {
    _render = tex;
    _broadcastEvent(onNewRender, WindowEvent._("onNewRender", render ?? Uint8List(0)));
  }

  // Events

  final List<bool Function(WindowEvent<dynamic>)> _eventPreprocessors = [];

  /// Registers an event preprocessor on this window. Return false to cancel event, otherwisse true.
  void registerPreprocessor(bool Function(WindowEvent<dynamic>) preprocessFn) {
    _eventPreprocessors.add(preprocessFn);
  }

  /// Unregister a previously registered preprocessor.
  void unregisterPreprocessor(bool Function(WindowEvent<dynamic>) preprocessFn) {
    _eventPreprocessors.remove(preprocessFn);
  }

  void _broadcastEvent(Event eventObj, WindowEvent<dynamic> eventArgs) {
    if (!_preprocessEvents(eventArgs)) return;
    eventObj.broadcast(eventArgs);
  }

  bool _preprocessEvents(WindowEvent<dynamic> event) {
    bool result = true;
    for (int i = 0; i < _eventPreprocessors.length && result; i++) {
      result = _eventPreprocessors[i](event);
    }
    return result;
  }

  final onTitleChanged = Event<WindowEvent<String>>();
  final onFocusChanged = Event<WindowEvent<bool>>();
  final onResizableChanged = Event<WindowEvent<bool>>();
  final onBackgroundRenderModeChanged = Event<WindowEvent<BackgroundMode>>();
  final onPosChanged = Event<WindowEvent<Vector2>>();
  final onSizeChanged = Event<WindowEvent<Vector2>>();
  final onMinSizeChanged = Event<WindowEvent<Vector2>>();
  final onStateChanged = Event<WindowEvent<WindowState>>();
  final onNewRender = Event<WindowEvent<Uint8List>>();

  final onEvent = Event<WindowEvent>();
}

enum WindowState { normal, maximized, minimized }

enum BackgroundMode { normal, blurredTransp }

class WindowEvent<T> extends EventArgs {
  final String id;
  final T value;

  WindowEvent._(this.id, this.value);
}