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
import 'package:mopicon/common/base_controller.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/pages/playlist/playlist_mixin.dart';
import 'package:mopicon/pages/tracklist/tracklist_mixin.dart';
import 'package:mopicon/services/mopidy_service.dart';

abstract class TracklistViewController extends BaseController {
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

  Future<void> addItemsToPlaylist<T>(BuildContext context, List<T> tracks, {Ref? playlist});

  Future<void> addItemsToTracklist<T>(BuildContext context, List<T> tracks);
}

class TracklistViewControllerImpl extends TracklistViewController with PlaylistMethods, TracklistMethods {
  TracklistViewControllerImpl() {
    mopidyService.tracklistChangedNotifier.addListener(() {
      _tracks.clear();
      _tracks.addAll(mopidyService.tracklistChangedNotifier.value);
    });
  }

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
    notifyUnselect();
  }

  @override
  Future<void> deleteTrack(int position) async {
    _deleteTracks([position]);
  }

  Future<void> _deleteTracks(List<int> tlids) async {
    int? tlid = (await mopidyService.getCurrentTlTrack())?.tlid;
    if (tlid != null && tlids.contains(tlid)) {
      await mopidyService.playback(PlaybackAction.stop, null);
    }
    mopidyService.deleteFromTracklist(tlids);
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
    var tr = await mopidyService.getTracklistTlTracks();
    _tracks.clear();
    _tracks.addAll(tr);
    return Future.value(_tracks);
  }
}
