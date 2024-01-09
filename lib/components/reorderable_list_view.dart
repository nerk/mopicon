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
import 'package:get_it/get_it.dart';
import 'package:mopicon/services/cover_service.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/services/preferences_service.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'selected_item_positions.dart';

typedef OnReorderCallback = void Function(int start, int current);
typedef OnTapCallback<T> = void Function(T item, int index);

class ReorderableTrackListView<T extends Object> {
  final _preferences = GetIt.instance<Preferences>();

  // uri/image map
  final BuildContext context;
  final List<T> items;
  final Map<String, Widget> images;
  final SelectionChangedNotifier selectionChangedNotifier;
  final SelectionModeChangedNotifier selectionModeChangedNotifier;
  final OnReorderCallback? onReorder;
  final OnTapCallback<T>? onTap;
  int? markedItemIndex;

  var selectedPositions = SelectedItemPositions();

  ReorderableTrackListView(this.context, this.items, this.images, this.selectionChangedNotifier,
      this.selectionModeChangedNotifier, this.onReorder, this.onTap,
      {this.markedItemIndex}) {
    assert(items is List<Track> || items is List<TlTrack>);
    selectedPositions = selectionChangedNotifier.value.clone();
  }

  Widget _getImage(T item, int index, bool toggle) {
    bool checked = selectedPositions.isSet(index);
    checked = toggle ? !checked : checked;
    if (checked) {
      return Padding(
        padding: const EdgeInsets.all(3),
        child: CircleAvatar(
          backgroundColor: _preferences.theme.data.colorScheme.inversePrimary,
          child: const Icon(Icons.check),
        ),
      );
    } else {
      return images[getUri(item)] ?? CoverService.defaultImage;
    }
  }

  Widget buildListView() {
    var listView = ReorderableListView.builder(
        buildDefaultDragHandles: false,
        shrinkWrap: items.length > 500,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) => _listItem(items[index], index),
        onReorder: (int start, int current) {
          if (onReorder != null) {
            selectedPositions.move(start, current, items.length);
            selectionChangedNotifier.value = selectedPositions;
            onReorder!(start, current);
          }
        });
    return Material(child: listView);
  }

  Widget _listItem(T item, int index) {
    var track = item is Track ? item : (item as TlTrack).track;

    var listTile = ListTile(
        contentPadding: const EdgeInsets.all(0),
        tileColor: index == markedItemIndex ? _preferences.theme.data.colorScheme.inversePrimary : null,
        onTap: () async {
          if (selectionModeChangedNotifier.value == SelectionMode.on) {
            selectedPositions.toggle(index);
            selectionChangedNotifier.value = selectedPositions;
            selectionModeChangedNotifier.value = selectedPositions.isEmpty ? SelectionMode.off : SelectionMode.on;
          } else if (onTap != null) {
            onTap!(item, index);
          }
        },
        leading: GestureDetector(
            onLongPress: () {
              selectionModeChangedNotifier.value = SelectionMode.on;
              selectedPositions.set(index);
              selectionChangedNotifier.value = selectedPositions;
            },
            child: _getImage(item, index, false)),
        title: Text(track.name),
        subtitle: track.artistNames != null ? Text(track.artistNames!) : null);

    return Dismissible(
        key: Key("$index$item"),
        background: Container(
          color: _preferences.theme.data.colorScheme.onBackground,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: const EdgeInsets.only(left: 4), child: _getImage(item, index, true)),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            selectedPositions.toggle(index);
            selectionChangedNotifier.value = selectedPositions;
            selectionModeChangedNotifier.value = selectedPositions.isEmpty ? SelectionMode.off : SelectionMode.on;
          }
          return false;
        },
        child: onReorder != null
            ? ReorderableDelayedDragStartListener(
                key: Key("$index$item.uri"),
                index: index,
                child: listTile,
              )
            : listTile);
  }
}
