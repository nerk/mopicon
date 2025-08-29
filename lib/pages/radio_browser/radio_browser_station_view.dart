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
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/components/rd_list_tile.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;

class RadioBrowserStationListView extends StatelessWidget {
  final List<radio.Station> stations;
  final SelectionChangedNotifier selectionChangedNotifier;
  final SelectionModeChangedNotifier selectionModeChangedNotifier;
  final void Function(radio.Station item, int index)? onTap;

  var selectedPositions = SelectedItemPositions();
  final preferences = GetIt.instance<PreferencesController>();

  RadioBrowserStationListView(
    this.stations,
    this.selectionChangedNotifier,
    this.selectionModeChangedNotifier,
    this.onTap, {
    super.key,
  }) {
    selectedPositions = selectionChangedNotifier.value.clone();
  }

  Widget _getImage(radio.Station station, int index, bool toggle) {
    bool checked = selectedPositions.isSet(index);
    checked = toggle ? !checked : checked;
    if (checked) {
      return Padding(
        padding: const EdgeInsets.all(0),
        child: CircleAvatar(backgroundColor: preferences.theme.data.colorScheme.inversePrimary, child: const Icon(Icons.check)),
      );
    } else {
      return loadImage(station.favicon);
    }
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      shrinkWrap: stations.length > 200,
      itemCount: stations.length,
      itemBuilder: (BuildContext context, int index) => _buildItem(context, index),
      //leading: null,
    );

    return Material(child: listView);
  }

  Widget _buildItem(BuildContext context, int index) {
    radio.Station item = stations[index];
    void onTapped() {
      if (selectionModeChangedNotifier.value == SelectionMode.on) {
        selectedPositions.toggle(index);
        selectionChangedNotifier.value = selectedPositions.clone();
        selectionModeChangedNotifier.value = selectedPositions.isEmpty ? SelectionMode.off : SelectionMode.on;
      } else {
        selectedPositions = SelectedItemPositions();
        selectionChangedNotifier.value = SelectedItemPositions();
        selectionModeChangedNotifier.value = SelectionMode.off;
        if (onTap != null) {
          onTap!(item, index);
        }
      }
    }

    return Builder(
      builder: (context) {
        return _listItem(context, index, onTapped);
      },
    );
  }

  Widget _listItem(BuildContext context, int index, void Function() onTapped) {
    var item = stations[index];
    //return ListTile(minLeadingWidth: 80, minTileHeight: 100, leading: _getImage(item, index, false), title: Text(item.name), subtitle: Text(item.favicon ?? ""));

    return RdListTile(
      index,
      key: Key("$index/$item.uri/$item.name"),
      onLongPress: () {
        selectionModeChangedNotifier.value = SelectionMode.on;
        selectedPositions.set(index);
        selectionChangedNotifier.value = selectedPositions;
      },
      onTap: onTapped,
      leading: _getImage(item, index, false),
      title: Text("${item.name} (${item.clickCount})", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      subtitle: Text(item.url, style: const TextStyle(fontSize: 12)),
      dismissibleBackgroundColor: preferences.theme.data.colorScheme.inversePrimary,
      canReorder: false,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          selectedPositions.toggle(index);
          selectionChangedNotifier.value = selectedPositions;
          selectionModeChangedNotifier.value = selectedPositions.isEmpty ? SelectionMode.off : SelectionMode.on;
        }
        return false;
      },
    );
  }

  Widget loadImage(String? uri) {
    if (uri != null && uri.isNotEmpty && !uri.endsWith('.svg') && !uri.endsWith('/null')) {
      try {
        var img = Image.network(
          uri,
          errorBuilder: (BuildContext context, Object obj, StackTrace? st) {
            logger.e(obj.toString());
            return SizedBox();
          },
        );
        return SizedBox(width: 80, height: 80, child: FittedBox(fit: BoxFit.cover, child: img));
      } catch (e, s) {
        logger.e(e, stackTrace: s);
      }
    }
    return ImageUtils.resize(FittedBox(fit: BoxFit.cover, child: Icon(Icons.radio)), 80, 80);
  }
}
