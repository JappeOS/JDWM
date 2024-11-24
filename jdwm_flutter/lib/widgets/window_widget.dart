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

class WindowWidget extends StatefulWidget {
  final WindowContent content;
  final Window window;

  const WindowWidget(
      {Key? key,
      required this.content,
      required this.window})
      : super(key: key);

  @override
  _WindowWidgetState createState() => _WindowWidgetState();
}

class _WindowWidgetState extends State<WindowWidget> {
  static const kResizeAreaThickness = 5.0;

  Vector2 oldWindowPos = Vector2.zero();
  Vector2 oldWindowSize = Vector2.zero();
  Offset? _dragOffset;
  bool _freeDrag = false;

  @override
  Widget build(BuildContext context) {
    Widget header() => ShadeHeaderBar(
      title: widget.window.title,
      backgroundColor: Colors.transparent,
      isActive: widget.window.isFocused,
      isClosable: true,
      isDraggable: true,
      isMaximizable: widget.window.state == WindowState.normal,
      isMinimizable: true,
      isRestorable: widget.window.state != WindowState.normal,
      onClose: (_) => widget.window._close(),
      onDrag: (_, p) {
        _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);

        if ((_dragOffset!.dx.abs() < 10 && _dragOffset!.dy.abs() < 10) && !_freeDrag) {
          return;
        }

        _freeDrag = true;

        widget.window.setPos(Vector2(
          oldWindowPos.x + _dragOffset!.dx,
          oldWindowPos.y + _dragOffset!.dy,
        ));
      },
      onDragStart: (_) {
        _dragOffset = Offset.zero;
        oldWindowPos = widget.window.pos;
        _freeDrag = false;
        widget.window.setFocus(true);
      },
      onDragEnd: (_) {
        _dragOffset = null;
        oldWindowPos = Vector2.zero();
        _freeDrag = false;

        if (widget.window.pos.y < -5) {
          widget.window.setPos(Vector2(widget.window.pos.x, 0));
        }
      },
      onMaximize: (_) => widget.window.setState(WindowState.maximized),
      onMinimize: (_) => widget.window.setState(WindowState.minimized),
      onRestore: (_) => widget.window.setState(WindowState.normal),
      // TODO: onShowMenu
    );

    // The window base widget, anything can be added on top later on
    Widget base(Widget child) {
      final borderRadius = widget.window.state == WindowState.normal ? BPPresets.medium : 0.0;
      final borderStyle = widget.window.state == WindowState.normal ? ShadeContainerBorder.double : ShadeContainerBorder.none;

      if (widget.window.bgRenderMode == BackgroundMode.blurredTransp) {
        // Blurred window background
        return ShadeContainer.transparent(
          borderRadius: borderRadius,
          border: borderStyle,
          backgroundBlur: true,
          child: child,
        );
      } else {
        // Solid window background
        return ShadeContainer.solid(
          borderRadius: borderRadius,
          border: borderStyle,
          child: child,
        );
      }
    }

    List<Widget> resizeAreas = !widget.window.isResizable || widget.window.state != WindowState.normal
        ? []
        : [
            // Right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);

                  widget.window.setSize(Vector2(
                    oldWindowSize.x + _dragOffset!.dx,
                    widget.window.size.y,
                  ));
                },
                MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  opaque: true,
                  child: Container(
                    width: kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // Left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);
                  bool sizeXIsMin = widget.window.minSize.x >= oldWindowSize.x - _dragOffset!.dx;

                  widget.window.setSize(Vector2(
                    oldWindowSize.x - _dragOffset!.dx,
                    widget.window.size.y,
                  ));

                  widget.window.setPos(Vector2(
                    oldWindowPos.x + (!sizeXIsMin ? _dragOffset!.dx : 0),
                    widget.window.pos.y,
                  ));
                },
                MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  opaque: true,
                  child: Container(
                    width: kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // Top
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);
                  bool sizeYIsMin = widget.window.minSize.y >= oldWindowSize.y - _dragOffset!.dy;

                  widget.window.setSize(Vector2(
                    widget.window.size.x,
                    oldWindowSize.y - _dragOffset!.dy,
                  ));

                  widget.window.setPos(Vector2(
                    widget.window.pos.x,
                    oldWindowPos.y + (!sizeYIsMin ? _dragOffset!.dy : 0),
                  ));
                },
                MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  opaque: true,
                  child: Container(
                    height: kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // Bottom
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);

                  widget.window.setSize(Vector2(
                    widget.window.size.x,
                    oldWindowSize.y + _dragOffset!.dy,
                  ));
                },
                MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  opaque: true,
                  child: Container(
                    height: kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // BottomRight
            Positioned(
              bottom: 0,
              right: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);

                  widget.window.setSize(Vector2(
                    oldWindowSize.x + _dragOffset!.dx,
                    oldWindowSize.y + _dragOffset!.dy,
                  ));
                },
                const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  opaque: true,
                  child: SizedBox(
                    height: 1.5 * kResizeAreaThickness,
                    width: 1.5 * kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // BottomLeft
            Positioned(
              bottom: 0,
              left: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);
                  bool sizeXIsMin = widget.window.minSize.x >= oldWindowSize.x - _dragOffset!.dx;

                  widget.window.setSize(Vector2(
                    oldWindowSize.x - _dragOffset!.dx,
                    oldWindowSize.y + _dragOffset!.dy,
                  ));

                  widget.window.setPos(Vector2(
                    oldWindowPos.x + (!sizeXIsMin ? _dragOffset!.dx : 0),
                    widget.window.pos.y,
                  ));
                },
                const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  opaque: true,
                  child: SizedBox(
                    height: 1.5 * kResizeAreaThickness,
                    width: 1.5 * kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // TopRight
            Positioned(
              top: 0,
              right: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);
                  bool sizeYIsMin = widget.window.minSize.y >= oldWindowSize.y - _dragOffset!.dy;

                  widget.window.setSize(Vector2(
                    oldWindowSize.x + _dragOffset!.dx,
                    oldWindowSize.y - _dragOffset!.dy,
                  ));

                  widget.window.setPos(Vector2(
                    widget.window.pos.x,
                    oldWindowPos.y + (!sizeYIsMin ? _dragOffset!.dy : 0),
                  ));
                },
                const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  opaque: true,
                  child: SizedBox(
                    height: 1.5 * kResizeAreaThickness,
                    width: 1.5 * kResizeAreaThickness,
                  ),
                ),
              ),
            ),
            // TopLeft
            Positioned(
              left: 0,
              top: 0,
              child: _resizeArea(
                (p) {
                  _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);
                  bool sizeXIsMin = widget.window.minSize.x >= oldWindowSize.x - _dragOffset!.dx;
                  bool sizeYIsMin = widget.window.minSize.y >= oldWindowSize.y - _dragOffset!.dy;

                  widget.window.setSize(Vector2(
                    oldWindowSize.x - _dragOffset!.dx,
                    oldWindowSize.y - _dragOffset!.dy,
                  ));

                  widget.window.setPos(Vector2(
                    oldWindowPos.x + (!sizeXIsMin ? _dragOffset!.dx : 0),
                    oldWindowPos.y + (!sizeYIsMin ? _dragOffset!.dy : 0),
                  ));
                },
                const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  opaque: true,
                  child: SizedBox(
                    height: 1.5 * kResizeAreaThickness,
                    width: 1.5 * kResizeAreaThickness,
                  ),
                ),
              ),
            ),
          ];

    return Stack(
      children: [
        Positioned(
          top: widget.window.state == WindowState.normal ? kResizeAreaThickness : 0,
          left: widget.window.state == WindowState.normal ? kResizeAreaThickness : 0,
          bottom: widget.window.state == WindowState.normal ? kResizeAreaThickness : 0,
          right: widget.window.state == WindowState.normal ? kResizeAreaThickness : 0,
          child: base(
            Column(
              children: [
                header(),
                Expanded(child: widget.content),
              ],
            ),
          ),
        ),
        ...resizeAreas
      ],
    );
  }

  Widget _resizeArea(void Function(PointerMoveEvent) onPointerMove, Widget child) {
    return Listener(
      onPointerMove: onPointerMove,
      onPointerDown: (p) {
        _dragOffset = Offset.zero;
        oldWindowSize = widget.window.size;
        oldWindowPos = widget.window.pos;
      },
      onPointerUp: (p) {
        _dragOffset = null;
        oldWindowSize = Vector2.zero();
        oldWindowPos = Vector2.zero();
      },
      child: child,
    );
  }
}