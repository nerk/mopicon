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
import 'package:mopicon/utils/globals.dart';
import 'playlist_view_controller.dart';
import 'package:mopicon/components/menu_builder.dart';
import 'package:mopicon/components/selected_item_positions.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/generated/l10n.dart';
import 'new_stream_dialog.dart';

class PlaylistAppBarMenu extends StatelessWidget {
  final PlaylistViewController controller;
  final Ref playlist;

  const PlaylistAppBarMenu(this.controller, this.playlist, {super.key});

  void _selectAll(BuildContext context, _, __) async {
    List<Track> tracks = await controller.getPlaylistItems(playlist);
    controller.selectionChanged.value = SelectedItemPositions.all(tracks.length);

    controller.selectionModeChanged.value =
        controller.selectionChanged.value.isNotEmpty ? SelectionMode.on : SelectionMode.off;
  }

  void _deleteAll(BuildContext context, _, __) async {
    await controller.deleteAllPlaylistItems(playlist);
  }

  void _newStream(BuildContext context, _, __) async {
    var uri = await newStreamDialog(S.of(context).newPlaylistStreamDialogTitle);
    if (uri != null && context.mounted) {
      try {
        // Server looks up a stream by its URI and assigns
        // the correct name. We therefore just pass an empty name.
        Ref track = Ref(uri, '', Ref.typeTrack);
        await controller.addItemsToPlaylist<Ref>(context, [track], playlist: playlist);
      } catch (e, s) {
        Globals.logger.e(e, stackTrace: s);
        if (context.mounted) {
          showError(S.of(context).newStreamCreateError, null);
        }
      }
    }
  }

  void _refresh(BuildContext context, _, __) async {
    controller.unselect();
    List<Track> tracks = await controller.getPlaylistItems(playlist);
    controller.playlistChangedNotifier.value = Playlist(playlist.uri, playlist.name, tracks, 0);
  }

  @override
  Widget build(BuildContext context) {
    return MenuBuilder()
        .addMenuItem(S.of(context).menuSelectAll, Icons.select_all, _selectAll)
        .addMenuItem(S.of(context).menuNewStream, Icons.cell_tower, _newStream)
        .addMenuItem(S.of(context).menuClearList, Icons.delete, _deleteAll)
        .addMenuItem(S.of(context).menuRefresh, Icons.refresh, _refresh)
        .addDivider()
        .addSettingsMenuItem(S.of(context).menuSettings)
        .addHelpMenuItem(S.of(context).menuAbout)
        .build(context, null, null);
  }
}
