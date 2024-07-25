/*
 * Copyright (c) 2024 Thomas Kern
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

import 'dart:async';
import 'package:flutter/material.dart';

/// Reorderable, dismissible list tile. Leading widget is vertically centered and
/// properly padded.
class RdListTile extends StatelessWidget {
  final int index;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Color? tileColor;
  final Color? dismissibleBackgroundColor;
  final bool? canReorder;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  const RdListTile(this.index,
      {this.title,
      this.subtitle,
      this.leading,
      this.tileColor,
      this.dismissibleBackgroundColor,
      this.onTap,
      this.onLongPress,
      this.canReorder,
      this.confirmDismiss,
      super.key});

  @override
  Widget build(BuildContext context) {
    var listTile = ListTile(
        dense: false,
        contentPadding: const EdgeInsets.only(left: 3, right: 3),
        tileColor: tileColor,
        onTap: onTap,
        title: Row(children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: leading,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (title != null) title!,
                if (subtitle != null) subtitle!,
              ])),
        ]));

    Widget tile = canReorder != null && canReorder == true
        ? ReorderableDelayedDragStartListener(
            key: Key("$index reorder"),
            index: index,
            child: listTile,
          )
        : listTile;

    return confirmDismiss != null
        ? Dismissible(
            key: Key("$index dismissible"),
            background: Container(
              color: dismissibleBackgroundColor,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.check)),
              ),
            ),
            confirmDismiss: confirmDismiss,
            child: tile)
        : tile;
  }
}
