/*
import 'package:flutter/material.dart';
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
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/pages/tracklist/tracklist_mixin.dart';

import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/components/selected_item_positions.dart';
import 'package:mopicon/pages/playlist/playlist_mixin.dart';

abstract class TracklistViewController {
  // toggle selection mode
  SelectionModeChangedNotifier get selectionModeChanged;
  SelectionChangedNotifier get selectionChanged;

  // Whether window is split between list of tracks and NowPlaying section.
  // If false, NowPlaying covers whole window and is showing more details.
  ValueNotifier<bool> get splitEnabled;

  Future<List<TlTrack>> loadTrackList();

  Future<List<Ref>> getSelectedItems();
  Future<void> deleteSelectedTracks();
  Future<void> deleteTrack(int position);

  //Future<List<Track>> getTracks();
  List<TlTrack> getTrackList();
  List<TlTrack> getSelectedTracks();

  Future<void> addItemsToPlaylist<T>(List<T> tracks, {Ref? playlist});
  Future<void> addItemsToTracklist<T>(List<T> tracks);

  void unselect();
}

class TracklistViewControllerImpl extends TracklistViewController with PlaylistMethods, TracklistMethods {
  final _mopidyService = GetIt.instance<MopidyService>();

  @override
  final selectionModeChanged = SelectionModeChangedNotifier(SelectionMode.off);

  @override
  final selectionChanged = SelectionChangedNotifier(SelectedItemPositions());

  @override
  final splitEnabled = ValueNotifier(true);

  // all tracks on the tracklist
  final _tracks = List<TlTrack>.empty(growable: true);

  @override
  Future<List<Ref>> getSelectedItems() async {
    return Future.value(selectionChanged.value.filterSelected(_tracks.asRef));
  }

  @override
  Future<void> deleteSelectedTracks() async {
    var tlids = List<int>.empty(growable: true);
    for (var i in selectionChanged.value.positions) {
      tlids.add(_tracks[i].tlid);
    }
    await _deleteTracks(tlids);
    selectionChanged.value = SelectedItemPositions();
    selectionModeChanged.value = SelectionMode.off;
  }

  @override
  Future<void> deleteTrack(int tlid) async {
    _deleteTracks([tlid]);
  }

  Future<void> _deleteTracks(List<int> tlids) async {
    int? tlid = (await _mopidyService.getCurrentTlTrack())?.tlid;
    if (tlid != null && tlids.contains(tlid)) {
      await _mopidyService.playback(PlaybackAction.stop, null);
    }
    _mopidyService.deleteFromTracklist(tlids);
  }

  @override
  List<TlTrack> getTrackList() {
    return _tracks;
  }

  @override
  List<TlTrack> getSelectedTracks() {
    List<TlTrack> result = List<TlTrack>.empty(growable: true);
    if (_tracks.isEmpty) {
      return result;
    }
    for (var pos in selectionChanged.value.positions) {
      result.add(_tracks[pos]);
    }
    return result;
  }

  @override
  Future<List<TlTrack>> loadTrackList() async {
    var tr = _mopidyService.tracklistChangedNotifier.value;
    if (tr.isEmpty) {
      tr = await _mopidyService.getTracklistTlTracks();
    }
    _tracks.clear();
    _tracks.addAll(tr);
    //WidgetsBinding.instance.addPostFrameCallback((_) => setState(() { }));
    return Future.value(_tracks);
  }

  @override
  void unselect() {
    selectionModeChanged.value = SelectionMode.off;
    selectionChanged.value.isNotEmpty ? selectionChanged.value = SelectedItemPositions() : null;
  }
}
