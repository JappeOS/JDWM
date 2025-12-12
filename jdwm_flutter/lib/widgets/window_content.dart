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

// TODO: Make stateless
class WindowContent extends StatefulWidget {
  final int? texture;

  const WindowContent({Key? key, this.texture}) : super(key: key);

  @override
  _WindowContentState createState() => _WindowContentState();
}

class _WindowContentState extends State<WindowContent> {
  @override
  Widget build(BuildContext context) {
    return widget.texture != null ? Texture(textureId: widget.texture!) : const SizedBox.shrink();
  }
}