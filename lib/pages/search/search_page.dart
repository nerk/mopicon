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
import 'dart:async';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/components/volume_control.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/components/reorderable_list_view.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/components/action_buttons.dart';
import 'package:mopicon/components/item_action_dialog.dart';

import 'search_view_controller.dart';
import 'search_appbar_menu.dart';

/// The search page displaying a SearchBar and the list of search results.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final mopidyService = GetIt.instance<MopidyService>();
  final TextEditingController textEditingController = TextEditingController();

  List<Track> tracks = [];
  var images = <String, Widget?>{};

  bool searchSupported = false;

  // selection mode (single/multiple) of track list view
  SelectionMode selectionMode = SelectionMode.off;

  final controller = GetIt.instance<SearchViewController>();

  Future<void> loadImages(List<Track> tracks) async {
    try {
      for (Track track in tracks) {
        if (images[track.uri] == null) {
          var image = await track.getImage();
          images.putIfAbsent(track.uri, () => image);
        }
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
    }
  }

  void updateSelection() {
    if (mounted) {
      setState(() {
        selectionMode = controller.selectionMode;
      });
    }
    //WidgetsBinding.instance.addPostFrameCallback((_) => setState(() { }));
  }

  void checkSearchSupported() async {
    if (mounted) {
      // Search is only supported if the Mopidy-Local extension is
      // enabled for the server. Just set a flag we can
      // check later.
      var canSearch = (await mopidyService.getUriSchemes()).contains('local');
      setState(() {
        searchSupported = canSearch;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkSearchSupported();
    controller.selectionModeChanged.addListener(updateSelection);
    controller.selectionChanged.addListener(updateSelection);
    updateSelection();
  }

  @override
  void dispose() {
    controller.selectionModeChanged.removeListener(updateSelection);
    controller.selectionChanged.removeListener(updateSelection);
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var listView = ReorderableTrackListView<Track>(
        context,
        tracks,
        images,
        controller.selectionChanged,
        controller.selectionModeChanged,
        null, (Track track, int index) async {
      var r = await showActionDialog([
        ItemActionOption.play,
        ItemActionOption.addToTracklist,
        ItemActionOption.addToPlaylist
      ]);
      if (!context.mounted) return;
      switch (r) {
        case ItemActionOption.play:
          await controller.addItemsToTracklist<Ref>(context, [track.asRef]);
          mopidyService.play(track.asRef);
          break;
        case ItemActionOption.addToTracklist:
          await controller.addItemsToTracklist<Ref>(context, [track.asRef]);
          break;
        case ItemActionOption.addToPlaylist:
          await controller.addItemsToPlaylist<Ref>(context, [track.asRef]);
          break;
        default:
      }
    }).buildListView();

    var pageContent = Column(mainAxisSize: MainAxisSize.max, children: [
      SearchBar(
        controller: textEditingController,
        padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onSubmitted: (String value) async {
          List<Track> trx = [];
          try {
            controller.mopidyService.setBusy(true);

            List<SearchResult> searchResult =
                await mopidyService.search(SearchCriteria().any([value]));
            trx = searchResult.first.tracks;
            if (trx.isNotEmpty) {
              await loadImages(trx);
            }
          } catch (e, s) {
            logger.e(e, stackTrace: s);
            trx = [];
          } finally {
            controller.mopidyService.setBusy(false);
            setState(() {
              tracks = trx;
            });
          }
        },
        leading: const Icon(Icons.search),
        trailing: <Widget>[
          IconButton(
            onPressed: () {
              textEditingController.clear();
              setState(() {
                tracks = [];
              });
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      Expanded(
          child:
              Padding(padding: const EdgeInsets.only(top: 12), child: listView))
    ]);

    var notSupported = Center(
        child: Text(S.of(context).searchPageNotSupportedMessage,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)));

    return Scaffold(
      appBar: AppBar(
          title: Text(S.of(context).searchPageTitle),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          leading: controller.selectionChanged.value.isNotEmpty
              ? ActionButton<SelectedItemPositions>(Icons.arrow_back, () {
                  controller.notifyUnselect();
                })
              : null,
          actions: [
            ActionButton<SelectedItemPositions>(Icons.queue_music, () async {
              var selectedItems =
                  controller.selectionChanged.value.filterSelected(tracks);
              await controller.addItemsToTracklist<Ref>(
                  context, selectedItems.asRef);
              controller.notifyUnselect();
            }, valueListenable: controller.selectionChanged),
            ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
              var selectedItems =
                  controller.selectionChanged.value.filterSelected(tracks);
              await controller.addItemsToPlaylist<Ref>(
                  context, selectedItems.asRef);
              controller.notifyUnselect();
            }, valueListenable: controller.selectionChanged),
            VolumeControl(),
            SearchAppBarMenu(tracks.length, controller)
          ]),
      body: MaterialPageFrame(
          child: searchSupported ? pageContent : notSupported),
    );
  }
}
