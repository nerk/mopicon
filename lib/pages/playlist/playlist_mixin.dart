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
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/pages/playlist/select_playlist_dialog.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/logging_utils.dart';

mixin PlaylistMethods {
  final _mopidyService = GetIt.instance<MopidyService>();

  Ref? recentPlaylist;

  Future<List<Track>> getPlaylistTracks<T>(T playlist) async {
    assert((playlist is Ref && playlist.type == Ref.typePlaylist) || playlist is Playlist);
    if (playlist is Ref) {
      return await _mopidyService.getPlaylistItems(playlist);
    } else {
      return (playlist as Playlist).tracks;
    }
  }

  Future<void> addItemsToPlaylist(BuildContext context, List<Ref> tracks, {Ref? playlist}) async {
    Playlist? plst;
    List<Ref> flattened = await _mopidyService.flatten<Ref>(tracks);
    try {
      if (playlist == null) {
        var playlists = await _mopidyService.getPlaylists();
        if (recentPlaylist != null && playlists.contains(recentPlaylist)) {
          // make most recent playlist top of the list
          playlists.removeAt(playlists.indexOf(recentPlaylist!));
          playlists.insert(0, recentPlaylist!);
        }

        Ref? pl = await selectPlaylistDialog(playlists);
        if (pl != null) {
          recentPlaylist = pl;
          plst = await _mopidyService.addToPlaylist(pl, flattened);
        }
      } else {
        plst = await _mopidyService.addToPlaylist(playlist, flattened);
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      context.mounted && plst != null ? showError(S.of(context).couldNotAddTracksToPlaylistError(plst.name), null) : null;
    } finally {
      if (context.mounted) {
        if (plst != null) {
          if (flattened.length > 1) {
            showInfo(S.of(context).tracksAddedToPlaylistMessage(flattened.length, plst.name), null);
          } else if (flattened.length == 1){
            showInfo(S.of(context).trackAddedToPlaylistMessage(plst.name), null);
          }
        }
      }
    }
  }
}
