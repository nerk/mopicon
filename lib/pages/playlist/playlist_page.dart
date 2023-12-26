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
import 'package:mopicon/components/action_buttons.dart';
import 'package:mopicon/components/volume_control.dart';
import 'package:mopicon/utils/globals.dart';
import 'package:mopicon/utils/parameters.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/components/reorderable_list_view.dart';
import 'package:mopicon/components/selected_item_positions.dart';
import 'package:mopicon/components/item_action_dialog.dart';

import 'playlist_view_controller.dart';
import 'playlist_appbar_menu.dart';

class PlaylistPage extends StatefulWidget {
  final String? title;
  final String? parent;

  const PlaylistPage({this.title, this.parent, super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final mopidyService = GetIt.instance<MopidyService>();

  late Ref playlist;
  List<Track> tracks = [];
  var images = <String, Widget>{};

  // selection mode (single/multiple) of track list view
  SelectionMode selectionMode = SelectionMode.off;

  final controller = GetIt.instance<PlaylistViewController>();

  Future loadPlaylistItems() async {
    try {
      if (widget.parent != null) {
        playlist = Ref.fromMap(Parameter.fromBase64(widget.parent!));
        controller.currentPlaylist = playlist;
      }

      var trx = await controller.getPlaylistItems(playlist);
      if (trx.isNotEmpty) {
        await loadImages(trx);

        if (mounted) {
          setState(() {
            tracks = trx;
          });
        }
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
    }
  }

  Future<void> loadImages(List<Track> tracks) async {
    for (Track track in tracks) {
      if (images[track.uri] == null) {
        var image = await track.getImage();
        images.putIfAbsent(track.uri, () => image);
      }
    }
  }

  void updateSelection() {
    if (mounted) {
      setState(() {
        selectionMode = controller.selectionModeChanged.value;
      });
    }
    //WidgetsBinding.instance.addPostFrameCallback((_) => setState(() { }));
  }

  @override
  void initState() {
    logger.d("initState: playlist $hashCode");
    super.initState();
    controller.playlistChangedNotifier.addListener(loadPlaylistItems);
    controller.selectionModeChanged.addListener(updateSelection);
    controller.selectionChanged.addListener(updateSelection);
    updateSelection();
    loadPlaylistItems();
  }

  @override
  void dispose() {
    logger.d("dispose: playlist $hashCode");
    controller.playlistChangedNotifier.removeListener(loadPlaylistItems);
    controller.selectionModeChanged.removeListener(updateSelection);
    controller.selectionChanged.removeListener(updateSelection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var listView = ReorderableTrackListView<Track>(
        context,
        tracks,
        images,
        controller.selectionChanged,
        controller.selectionModeChanged, (int start, int current) async {
      try {
        if (start < current) {
          await mopidyService.movePlaylistItem(playlist, start, current - 1);
        } else {
          await mopidyService.movePlaylistItem(playlist, start, current);
        }
      } catch (e) {
        logger.e(e);
      }
    }, (Track track, int index) async {
      var r = await showActionDialog([
        ItemActionOption.play,
        ItemActionOption.addToTracklist,
        ItemActionOption.addToPlaylist
      ]);
      switch (r) {
        case ItemActionOption.play:
          await controller.addItemsToTracklist<Ref>([track.asRef]);
          mopidyService.play(track.asRef);
          break;
        case ItemActionOption.addToTracklist:
          await controller.addItemsToTracklist<Ref>([track.asRef]);
          break;
        case ItemActionOption.addToPlaylist:
          await controller.addItemsToPlaylist<Ref>([track.asRef]);
          break;
        default:
      }
    }).buildListView();

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title ?? S.of(context).playlistPageTitle),
          centerTitle: true,
          //automaticallyImplyLeading: true,
          leading: ActionButton<SelectedItemPositions>(Icons.arrow_back, () {
            if (controller.selectionChanged.value.isEmpty) {
              Navigator.of(context).pop();
            } else {
              controller.unselect();
            }
          }),
          actions: [
            ActionButton<SelectedItemPositions>(
                Icons.delete,
                valueListenable: controller.selectionChanged,
                () => controller.deleteSelectedPlaylistItems(playlist)),
            ActionButton<SelectedItemPositions>(Icons.queue_music, () async {
              var selectedItems = await controller.getSelectedItems(playlist);
              await controller.addItemsToTracklist<Ref>(selectedItems.asRef);
              controller.unselect();
            }, valueListenable: controller.selectionChanged),
            ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
              var selectedItems = await controller.getSelectedItems(playlist);
              await controller.addItemsToPlaylist<Ref>(selectedItems.asRef);
              controller.unselect();
            }, valueListenable: controller.selectionChanged),
            VolumeControl(),
            PlaylistAppBarMenu(controller, playlist)
          ]),
      body: MaterialPageFrame(child: listView),
    );
  }
}
