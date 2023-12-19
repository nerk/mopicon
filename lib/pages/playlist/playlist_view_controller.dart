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
import 'package:mopicon/components/selected_item_positions.dart';
import 'package:mopicon/pages/tracklist/tracklist_mixin.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/pages/playlist/playlist_mixin.dart';

abstract class PlaylistViewController with TracklistMethods, PlaylistMethods {
  ValueNotifier<Playlist?> get playlistChangedNotifier;
  // toggle selection mode
  SelectionModeChangedNotifier get selectionModeChanged;
  SelectionChangedNotifier get selectionChanged;

  Future<List<Track>> getPlaylistItems(Ref playlist);
  Future<void> deletePlaylistItem(Ref playlist, int position);
  Future<void> deleteSelectedPlaylistItems(Ref playlist);
  Future<void> deleteAllPlaylistItems(Ref playlist);
  Future<List<Track>> getSelectedItems(Ref playlist);

  Ref? currentPlaylist;

  void unselect();
}

class PlaylistControllerImpl extends PlaylistViewController {
  final mopidyService = GetIt.instance<MopidyService>();

  @override
  final selectionModeChanged = SelectionModeChangedNotifier(SelectionMode.off);

  @override
  final selectionChanged = SelectionChangedNotifier(SelectedItemPositions());

  @override
  ValueNotifier<Playlist?> get playlistChangedNotifier =>
      mopidyService.playlistChangedNotifier;

  @override
  Future<List<Track>> getPlaylistItems(Ref playlist) async {
    return mopidyService.getPlaylistItems(playlist);
  }

  @override
  Future<Playlist?> deleteSelectedPlaylistItems(Ref playlist) async {
    Playlist? pl = await mopidyService.deletePlaylistItems(
        playlist, selectionChanged.value);
    selectionChanged.value = SelectedItemPositions();
    return pl;
  }

  @override
  Future<void> deleteAllPlaylistItems(Ref playlist) async {
    var items = await mopidyService.getPlaylistItems(playlist);
    await mopidyService.deletePlaylistItems(
        playlist, SelectedItemPositions.all(items.length));
    unselect();
  }

  @override
  Future<Playlist?> deletePlaylistItem(Ref playlist, int position) async {
    var sel = SelectedItemPositions()..set(position);
    Playlist? pl = await mopidyService.deletePlaylistItems(playlist, sel);

    if (selectionChanged.value.positions.contains(position)) {
      selectionChanged.value = selectionChanged.value.clone()..clear(position);
    }
    return pl;
  }

  @override
  Future<List<Track>> getSelectedItems(Ref playlist) async {
    var items = await mopidyService.getPlaylistItems(playlist);
    return selectionChanged.value.filterSelected<Track>(items);
  }

  @override
  void unselect() {
    selectionModeChanged.value = SelectionMode.off;
    selectionChanged.value.isNotEmpty
        ? selectionChanged.value = SelectedItemPositions()
        : null;
  }
}
