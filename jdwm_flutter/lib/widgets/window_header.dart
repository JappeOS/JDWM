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

class WindowHeader extends StatefulWidget {
  final ImageProvider? icon;
  final String? title;
  final bool maximizeButton;
  final Widget? customWindowDecorations;
  final Color? customColor;

  final Vector2 windowPos;
  final WindowState windowState;

  final Function(bool newVal) focusCallback;
  final Function(Vector2 newVal) posCallback;
  final Function(WindowState newVal) stateCallback;
  final Function() closeCallback;

  const WindowHeader(
      {Key? key,
      this.icon,
      this.title,
      this.maximizeButton = true,
      this.customWindowDecorations,
      this.customColor,
      required this.windowPos,
      required this.windowState,
      required this.focusCallback,
      required this.posCallback,
      required this.stateCallback,
      required this.closeCallback})
      : super(key: key);

  @override
  _WindowHeaderState createState() => _WindowHeaderState();
}

class _WindowHeaderState extends State<WindowHeader> {
  Vector2 oldWindowPos = Vector2.zero();
  Offset? _dragOffset;
  bool _freeDrag = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.customWindowDecorations != null ? 45 : 35,
      color: widget.customColor ?? Theme.of(context).colorScheme.background,
      child: Listener(
        behavior: HitTestBehavior.translucent,

        // When the window is dragged
        onPointerMove: (p) {
          _dragOffset = Offset(_dragOffset!.dx + p.delta.dx, _dragOffset!.dy + p.delta.dy);

          if ((_dragOffset!.dx.abs() < 10 && _dragOffset!.dy.abs() < 10) && !_freeDrag) {
            return;
          }

          _freeDrag = true;

          widget.posCallback(Vector2(
            oldWindowPos.x + _dragOffset!.dx,
            oldWindowPos.y + _dragOffset!.dy,
          ));
        },

        // When the titlebar is pressed
        onPointerDown: (p) {
          _dragOffset = Offset.zero;
          oldWindowPos = widget.windowPos;
          _freeDrag = false;
          widget.focusCallback(true);
        },

        onPointerUp: (p) {
          _dragOffset = null;
          oldWindowPos = Vector2.zero();
          _freeDrag = false;

          if (widget.windowPos.y < -5) {
            widget.posCallback(Vector2(widget.windowPos.x, 0));
          }
        },

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) Image(image: widget.icon!),
            if (widget.title != null) Text(widget.title!),
            if (widget.customWindowDecorations != null) ...[
              Expanded(child: widget.customWindowDecorations!),
            ] else
              const Spacer(),
            _getWindowControlButton(context, Icons.minimize, () => widget.stateCallback(WindowState.minimized)),
            if (widget.maximizeButton) ...[
              if (widget.windowState == WindowState.normal) ...[
                _getWindowControlButton(context, Icons.crop_square, () => widget.stateCallback(WindowState.maximized)),
              ] else
                _getWindowControlButton(context, Icons.fullscreen_exit, () => widget.stateCallback(WindowState.normal)),
            ],
            _getWindowControlButton(context, Icons.close, () => widget.closeCallback()),
          ],
        ),
      ),
    );
  }

  Widget _getWindowControlButton(BuildContext context, IconData icon, Function()? onPress) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: SizedBox(
        width: 30,
        height: 30,
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: Colors.transparent,
              mouseCursor: SystemMouseCursors.alias,
              borderRadius: BorderRadius.circular(30),
              onTap: onPress,
              child: Center(
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).colorScheme.onInverseSurface),
                  child: Icon(
                    icon,
                    size: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}