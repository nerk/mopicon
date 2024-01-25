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
  Future<bool?> Function(DismissDirection)? confirmDismiss;

  RdListTile(this.index,
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
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null) title!,
            if (subtitle != null) subtitle!,
          ]))
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
                child: Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check)),
              ),
            ),
            confirmDismiss: confirmDismiss,
            child: tile)
        : tile;
  }
}
