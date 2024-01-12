/*
 * Copyright (c) 2023 Thomas Kern
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mopicon/common/selected_item_positions.dart';

/// An IconButton with additional ValueListenable to control whether the button is shown.
///
/// [iconData] defines the icon of the created button.
///
/// If the [onPressed] callback is null, then the button will be disabled and
/// will not react to touch.
///
/// If [valueListenable] is provided, the concrete value of [T] is used to determine if the button should be displayed.
class ActionButton<T> extends StatelessWidget {
  final IconData iconData;

  /// The [VoidCallback] which is called if the button is pressed.
  ///
  /// If [onPressed] is null, the button is disabled.
  final VoidCallback onPressed;

  /// The [ValueListenable] to control whether the button is displayed.
  final ValueListenable<T>? valueListenable;

  const ActionButton(this.iconData, this.onPressed, {this.valueListenable, super.key});

  bool _shouldEnable(T value) {
    if (value == null) {
      return false;
    }

    if (value is SelectedItemPositions && value.positions.isNotEmpty) {
      return true;
    }

    if (value is List && value.isNotEmpty) {
      return true;
    }

    if (value is Set && value.isNotEmpty) {
      return true;
    }

    if (value is bool && value) {
      return true;
    }

    if (value is int || value is double && value != 0) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (valueListenable != null) {
      return ValueListenableBuilder<T>(
          valueListenable: valueListenable!,
          builder: (context, value, child) {
            if (_shouldEnable(value)) {
              return IconButton(icon: Icon(iconData), onPressed: onPressed);
            } else {
              return const SizedBox();
            }
          });
    } else {
      return IconButton(icon: Icon(iconData), onPressed: onPressed);
    }
  }
}
