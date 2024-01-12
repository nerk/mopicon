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
import 'package:mopicon/components/titled_divider.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:mopicon/pages/browse/album_list_item.dart';
import 'package:mopicon/routes/application_routes.dart';
import 'package:mopicon/utils/parameters.dart';
import 'package:mopicon/utils/image_utils.dart';

class LibraryListView {
  // uri/image map
  final Ref? parent;
  final List<Ref> items;
  final Map<String, Widget> images;
  final SelectionChangedNotifier selectionChangedNotifier;
  final SelectionModeChangedNotifier selectionModeChangedNotifier;
  final void Function(Ref item, int index)? onTap;

  var selectedPositions = SelectedItemPositions();
  final preferences = GetIt.instance<PreferencesController>();

  LibraryListView(this.parent, this.items, this.images, this.selectionChangedNotifier,
      this.selectionModeChangedNotifier, this.onTap) {
    selectedPositions = selectionChangedNotifier.value.clone();
  }

  Widget _getImage(Ref item, int index, bool toggle) {
    bool checked = selectedPositions.isSet(index);
    checked = toggle ? !checked : checked;
    if (checked) {
      return Padding(
        padding: const EdgeInsets.all(3),
        child: CircleAvatar(
          backgroundColor: preferences.theme.data.colorScheme.inversePrimary,
          child: const Icon(Icons.check),
        ),
      );
    } else if (item.type == Ref.typeTrack) {
      return images[getUri(item)]!;
    } else {
      return ImageUtils.getIconForType(item.uri, item.type);
    }
  }

  ListView build() {
    var listView = ListView.separated(
      shrinkWrap: items.length > 500,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => _buildItem(context, index),
      separatorBuilder: (BuildContext context, int index) => parent == null &&
              items[index].type == Ref.typeDirectory &&
              index < items.length - 1 &&
              items[index + 1].type == Ref.typePlaylist
          ? TitledDivider(S.of(context).libraryPlaylistSeparator)
          : const SizedBox(),
      //leading: null,
    );

    return listView;
  }

  Widget _buildItem(BuildContext context, int index) {
    Ref item = items[index];
    void onTapped() {
      if (selectionModeChangedNotifier.value == SelectionMode.on &&
          (item.type == Ref.typeTrack || item.type == Ref.typePlaylist)) {
        selectedPositions.toggle(index);
        selectionChangedNotifier.value = selectedPositions.clone();
        selectionModeChangedNotifier.value = selectedPositions.isEmpty ? SelectionMode.off : SelectionMode.on;
      } else {
        selectedPositions = SelectedItemPositions();
        selectionChangedNotifier.value = SelectedItemPositions();
        selectionModeChangedNotifier.value = SelectionMode.off;
        if (item.type == Ref.typePlaylist) {
          context.pushNamed(ApplicationRoutes.playlist,
              queryParameters: <String, String>{'title': item.name},
              pathParameters: <String, String>{'parent': Parameter.toBase64(item.toMap())});
        } else if (item.type != Ref.typeTrack) {
          context.pushNamed(ApplicationRoutes.down,
              queryParameters: <String, String>{'title': item.name},
              pathParameters: <String, String>{'parent': Parameter.toBase64(item.toMap())});
        } else if (onTap != null) {
          onTap!(item, index);
        }
      }
    }

    return Builder(builder: (context) {
      if (item.type == Ref.typeAlbum) {
        return _albumItem(context, index, parent, onTapped);
      } else {
        return _listItem(context, index, onTapped);
      }
    });
  }

  Widget _listItem(BuildContext context, int index, void Function() onTapped) {
    Ref item = items[index];
    var listTile = ListTile(
        key: Key("$index$item.uri"),
        contentPadding: const EdgeInsets.all(0),
        onLongPress: item.type == Ref.typeTrack || item.type == Ref.typePlaylist
            ? () {
                selectionModeChangedNotifier.value = SelectionMode.on;
                selectedPositions.set(index);
                selectionChangedNotifier.value = selectedPositions;
              }
            : null,
        onTap: onTapped,
        leading: _getImage(item, index, false),
        title: Text(item.name),
        subtitle: item.artistNames != null ? Text(item.artistNames!) : null);

    if (item.type == Ref.typeTrack || item.type == Ref.typePlaylist) {
      return Dismissible(
          key: Key("$index$item"),
          background: Container(
            color: preferences.theme.data.colorScheme.onBackground,
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
          child: listTile);
    } else {
      return listTile;
    }
  }

  Widget _albumItem(BuildContext context, int index, Ref? parent, Function() onTapped) {
    Ref item = items[index];
    var artistName = '';
    int? numTracks;
    String? date;
    if (item.extraData is AlbumInfoExtraData) {
      artistName = (item.extraData as AlbumInfoExtraData).artistNames;
      numTracks = (item.extraData as AlbumInfoExtraData).numTracks;
      date = (item.extraData as AlbumInfoExtraData).date;
    }
    return Card(
        child: AlbumListItem(
            item,
            ImageUtils.roundedCornersWithPadding(
                images[item.uri], ImageUtils.defaultCoverSize, ImageUtils.defaultCoverSize),
            item.name,
            artistName,
            numTracks,
            date,
            onTapped));
  }
}
