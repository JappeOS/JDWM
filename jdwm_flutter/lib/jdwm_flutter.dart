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

library jdwm_flutter;

import 'dart:typed_data';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:prioritized_event/prioritized_event.dart';
import 'package:shade_ui/shade_ui.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/*
  base
*/
part 'base/window_stack_controller.dart';
part 'base/window.dart';

/*
  widgets
*/
part 'widgets/window_content.dart';
part 'widgets/window_stack.dart';
part 'widgets/window_widget.dart';