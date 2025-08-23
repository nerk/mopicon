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
import 'package:flutter/services.dart';

class ModalDialog extends StatefulWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final int? defaultActionIndex;
  final bool? constrainSize;

  const ModalDialog(this.title, this.content, this.actions, {this.defaultActionIndex, this.constrainSize, super.key});

  @override
  State<ModalDialog> createState() => _ModalDialogState();
}

class _ModalDialogState extends State<ModalDialog> {
  @override
  Widget build(BuildContext context) {
    assert(
      widget.defaultActionIndex == null || (widget.defaultActionIndex! >= 0 && widget.defaultActionIndex! < widget.actions.length),
    );

    var height = (widget.constrainSize ?? false) ? MediaQuery.of(context).size.height / 2 : null;
    var width = (widget.constrainSize ?? false) ? MediaQuery.of(context).size.width / 1.5 : null;

    if (widget.defaultActionIndex != null) {
      return KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (v) {
          if (v.logicalKey == LogicalKeyboardKey.enter || v.logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (widget.defaultActionIndex != null) {
              var action = widget.actions[widget.defaultActionIndex!];
              if (action is ButtonStyleButton) {
                if (action.onPressed != null) {
                  action.onPressed!();
                }
              }
            }
          }
        },
        child: AlertDialog(
          title: widget.title,
          content: SizedBox(width: width, height: height, child: widget.content),
          actions: widget.actions,
        ),
      );
    } else {
      return AlertDialog(
        title: widget.title,
        content: SizedBox(width: width, height: height, child: widget.content),
        actions: widget.actions,
      );
    }
  }
}
