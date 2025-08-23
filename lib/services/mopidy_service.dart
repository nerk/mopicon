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
import 'package:universal_io/io.dart' show Platform;

import 'package:flutter/material.dart' show BuildContext, ValueNotifier;
import 'package:mopicon/utils/cache.dart';
import 'package:flutter/services.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopidy_client/mopidy_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/utils/open_value_notifier.dart';
export 'package:mopidy_client/mopidy_client.dart' hide Image;
import 'package:mopicon/generated/l10n.dart';

/// Enum to control playback of a track.
enum PlaybackAction { stop, pause, play, resume }

enum MopidyConnectionState { online, offline, reconnecting }

/// Access layer to Mopidy
abstract class MopidyService {
  /// Notification about current connection state.
  Stream<MopidyConnectionState> get connectionState$;

  /// Notification about operation state
  Stream<bool> get busyState$;

  void setBusy(bool busy);

  /// Notification to trigger refresh.
  Stream<bool> get refresh$;

  /// Notifier if items were added or removed from the tracklist.
  ValueNotifier<List<TlTrack>> get tracklistChangedNotifier;

  /// Notifiers about playback state of a track
  ValueNotifier<TrackPlaybackInfo?> get trackPlaybackNotifier;

  ValueNotifier<PlaybackState?> get playbackStateNotifier;

  /// Time position in currently playing track changed.
  OpenValueNotifier<int> get seekedNotifier;

  /// Notifier for mute or unmute.
  ValueNotifier<bool> get muteChangedNotifier;

  /// Notification about changes to the volume.
  ValueNotifier<int> get volumeChangedNotifier;

  /// Whether the title of a stream changed.
  ValueNotifier<String?> get streamTitleChangedNotifier;

  /// Notification about creation or deletion of a playlist.
  ValueNotifier<List<Ref>> get playlistsChangedNotifier;

  /// Notification if track was added to or deleted from a playlist.
  ValueNotifier<Playlist?> get playlistChangedNotifier;

  // Connection methods

  Future<bool> connect(String uri, {int? maxRetries});

  Future<MopidyConnectionState> waitConnected();

  void stop();

  Future<bool> resume();

  bool get connected;

  bool get stopped;

  // List of URI schemes supported by the server
  Future<List<String>> getUriSchemes();

  //
  // Library browser.
  //
  Future<List<Ref>> browse(Ref? parent);

  Future<Track?> lookupTrack(Ref parent);

  Future<List<SearchResult>> search(SearchCriteria criteria, {bool exact});

  Future<Map<String, List<MImage>>> getImages(List<String> uris);

  /// Returns a flattened list for [items].
  ///
  /// If an item on [items] has children, add all its children to
  /// the result list. Otherwise, add the item directly.
  /// This is only one level deep and not recursive. If an item has children,
  /// only the children which are tracks are added.
  Future<List<T>> flatten<T>(List<T> items, {Ref? playlist});

  //
  // Tracklist methods
  //
  Future<List<TlTrack>> addTracksToTracklist<T>(List<T> tracks);

  Future<List<TlTrack>> addTrackToTracklist<T>(T track);

  Future<int> getTracklistLength();

  Future<List<TlTrack>> getTracklistTlTracks();

  Future<TlTrack?> getCurrentTlTrack();

  Future<int?> getPreviousTlid();

  Future<int?> getNextTlid();

  Future<int> getLastTrackId(Ref track);

  Future<void> move(int from, int to);

  Future<void> clearTracklist();

  Future<void> deleteFromTracklist(List<int> tlids);

  //
  // Playback methods
  //
  Future<void> play(Ref track);

  Future<void> playback(PlaybackAction action, int? tlId);

  Future<void> playNext();

  Future<void> playPrevious();

  Future<String?> getPlaybackState();

  Future<int?> getTimePosition();

  Future<bool> seek(int timePosition);

  Future<String?> getStreamTitle();

  //
  // Playlist methods
  //
  Future<List<Ref>> getPlaylists();

  Future<List<Track>> getPlaylistItems(Ref playlist);

  Future<Playlist?> createPlaylist(String name);

  Future<Playlist?> savePlaylist(Playlist playlist);

  Future<bool> deletePlaylist(Ref playlist);

  Future<Playlist?> addToPlaylist<T>(
      BuildContext context, Ref playlist, List<T> items);

  Future<void> movePlaylistItem(Ref playlist, int from, int to);

  Future<Playlist?> deletePlaylistItems(
      Ref playlist, SelectedItemPositions positions);

  Future<bool> renamePlaylist(Ref playlist, String name);

  // Mixer
  Future<bool> setMute(bool mute);

  Future<bool> isMuted();

  Future<bool> setVolume(int volume);

  Future<int> getVolume();
}

class MopidyServiceImpl extends MopidyService {
  /// Notification about current connection state.
  final _connectionState$ = PublishSubject<MopidyConnectionState>();

  /// Notification about current operation state.
  final _busyState$ = PublishSubject<bool>();

  /// Notifier if items were added or removed from the tracklist.
  final _tracklistChangedNotifier = ValueNotifier<List<TlTrack>>([]);

  /// Notifiers about playback state of a track
  final _trackPlaybackNotifier = ValueNotifier<TrackPlaybackInfo?>(null);
  final _playbackStateNotifier = ValueNotifier<PlaybackState?>(null);

  /// Time position in currently playing track changed
  final _seekedNotifier = OpenValueNotifier<int>(0);

  /// Notifier for mute or unmute.
  final _muteChangedNotifier = ValueNotifier<bool>(false);

  /// Notification about changes to the volume.
  final _volumeChangedNotifier = ValueNotifier<int>(0);

  /// Whether the title of a stream changed.
  final _streamTitleChangedNotifier = ValueNotifier<String?>(null);

  /// Notification about creation or deletion of a playlist.
  final _playlistsChangedNotifier = ValueNotifier<List<Ref>>(List.empty());

  /// Notification if track was added to or deleted from a playlist.
  final _playlistChangedNotifier = ValueNotifier<Playlist?>(null);

  /// Notification to trigger refresh.
  final _refresh$ = PublishSubject<bool>();

  @override
  Stream<bool> get busyState$ => _busyState$.stream;

  @override
  Stream<bool> get refresh$ => _refresh$.stream;

  @override
  Stream<MopidyConnectionState> get connectionState$ =>
      _connectionState$.stream;

  @override
  ValueNotifier<List<TlTrack>> get tracklistChangedNotifier =>
      _tracklistChangedNotifier;

  @override
  ValueNotifier<TrackPlaybackInfo?> get trackPlaybackNotifier =>
      _trackPlaybackNotifier;

  @override
  ValueNotifier<PlaybackState?> get playbackStateNotifier =>
      _playbackStateNotifier;

  @override
  OpenValueNotifier<int> get seekedNotifier => _seekedNotifier;

  @override
  ValueNotifier<bool> get muteChangedNotifier => _muteChangedNotifier;

  @override
  ValueNotifier<int> get volumeChangedNotifier => _volumeChangedNotifier;

  @override
  ValueNotifier<String?> get streamTitleChangedNotifier =>
      _streamTitleChangedNotifier;

  @override
  ValueNotifier<List<Ref>> get playlistsChangedNotifier =>
      _playlistsChangedNotifier;

  @override
  ValueNotifier<Playlist?> get playlistChangedNotifier =>
      _playlistChangedNotifier;

  final Mopidy _mopidy;

  // indicator whether application is currently connected to a Mopidy server
  bool _connected = false;

  // Trying to establish a connection was explicitly stopped by user
  bool _stopped = false;

  // nested busy level tracking
  int _busyLevel = 0;

  // application is in paused application state
  bool _applicationPaused = false;

  // cached current volume
  int? _savedVolume;

  // cached current mute state
  bool? _savedMuteState;

  // cached album extra info
  final _albumDataCache = Cache<AlbumInfoExtraData>(1000, 2000);

  MopidyServiceImpl()
      : _mopidy = Mopidy(
            logger: logger, backoffDelayMin: 500, backoffDelayMax: 16000) {
    if (Platform.isAndroid) {
      SystemChannels.lifecycle.setMessageHandler((msg) {
        logger.i(msg);
        // When the app was resumed, update
        // tracklist state.
        if (msg == 'AppLifecycleState.resumed') {
          _applicationPaused = false;
          if (!connected) {
            resume();
          }
        } else if (msg == 'AppLifecycleState.paused') {
          _applicationPaused = true;
          stop();
        }
        return Future.value(null);
      });
    }

    _mopidy.clientState$.listen((value) {
      switch (value.state) {
        case ClientState.online:
          _stopped = false;
          _connected = true;
          _connectionState$.add(MopidyConnectionState.online);
          break;
        case ClientState.offline:
          _connected = false;
          // only notify subscribers if application is not paused
          if (!_applicationPaused) {
            _connectionState$.add(MopidyConnectionState.offline);
          }
          break;
        case ClientState.reconnecting:
          _connected = false;
          if (!_applicationPaused) {
            _connectionState$.add(MopidyConnectionState.reconnecting);
          }
          break;
        case ClientState.reconnectionPending:
          _connected = false;
          break;
      }
    });

    _mopidy.tracklistChanged$.listen((_) async {
      tracklistChangedNotifier.value = await getTracklistTlTracks();
    });

    _mopidy.trackPlayback$.listen((playbackInfo) {
      trackPlaybackNotifier.value = playbackInfo;
    });

    _mopidy.playbackStateChanged$.listen((playbackState) {
      playbackStateNotifier.value = playbackState;
    });

    _mopidy.seeked$.listen((timePosition) {
      bool explicitNotify = timePosition == seekedNotifier.value;
      seekedNotifier.value = timePosition;
      // explicitly trigger listeners if old and value are the same
      explicitNotify ? seekedNotifier.notify() : null;
    });

    _mopidy.playlistDeleted$.listen((Uri uri) async {
      playlistsChangedNotifier.value = await _mopidy.playlists.asList();
    });

    _mopidy.playlistChanged$.listen((Playlist playlist) async {
      playlistChangedNotifier.value = playlist;
    });

    _mopidy.muteChanged$.listen((muted) {
      muteChangedNotifier.value = muted;
    });

    _mopidy.volumeChanged$.listen((volume) {
      volumeChangedNotifier.value = volume;
    });

    _mopidy.streamTitleChanged$.listen((title) {
      streamTitleChangedNotifier.value = title;
    });
  }

  @override
  void setBusy(bool busy) {
    if (busy) {
      _busyLevel++;
      if (_busyLevel == 1) {
        _busyState$.add(true);
      }
    } else {
      _busyLevel--;
      if (_busyLevel <= 0) {
        _busyLevel = 0;
        _busyState$.add(false);
      }
    }
  }

  void _notifyRefresh() {
    _refresh$.add(true);
  }

  @override
  Future<MopidyConnectionState> waitConnected() {
    if (!_connected) {
      return connectionState$.firstWhere((MopidyConnectionState info) {
        return info == MopidyConnectionState.online;
      });
    } else {
      return Future<MopidyConnectionState>.value(MopidyConnectionState.online);
    }
  }

  @override
  Future<List<String>> getUriSchemes() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.getUriSchemes();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  bool get stopped => _stopped;

  @override
  Future<bool> connect(String uri, {int? maxRetries}) async {
    _albumDataCache.clear();
    _connected = false;
    _mopidy.disconnect();
    logger.i("Connecting to $uri");
    bool success =
        await _mopidy.connect(webSocketUrl: uri, maxRetries: maxRetries);
    if (success) {
      _notifyRefresh();
    }
    return success;
  }

  @override
  void stop() {
    logger.i("Stopping connection");
    _connected = false;
    _stopped = true;
    _mopidy.disconnect();
  }

  @override
  Future<bool> resume() async {
    logger.i("Resuming connection");
    _connected = false;
    _mopidy.disconnect();
    bool success = await _mopidy.connect();
    if (success) {
      _notifyRefresh();
    }
    return success;
  }

  @override
  bool get connected => _connected;

  @override
  Future<List<Ref>> browse(Ref? parent) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        var refs = await _mopidy.library.browse(parent?.uri);
        // lookup and add album extra info
        List<String> uris = refs
            .map((e) => e.type == Ref.typeAlbum ? e.uri : null)
            .nonNulls
            .toList();
        if (uris.isNotEmpty) {
          // warm up cache
          _loadAlbumExtraData(uris);
          for (var ref in refs) {
            var info = _albumDataCache.get(ref.uri);
            // cache miss
            info = info ?? (await _getAlbumExtraInfo([ref.uri]))[ref.uri];
            if (info != null) {
              ref.extraData = info;
              _albumDataCache.put(ref.uri, ref.extraData);
            }
          }
        }
        return refs;
      } finally {
        setBusy(false);
      }
    });
  }

  void _loadAlbumExtraData(List<String> uris) async {
    var notCached = uris
        .map((uri) => !_albumDataCache.contains(uri) ? uri : null)
        .nonNulls
        .toList();
    if (notCached.isNotEmpty) {
      _albumDataCache.putAll(await _getAlbumExtraInfo(notCached));
    }
  }

  Future<Map<String, AlbumInfoExtraData>> _getAlbumExtraInfo(
      List<String> uris) async {
    var result = <String, AlbumInfoExtraData>{};
    Map<String, List<Track>> trackMap = await _mopidy.library.lookup(uris);
    if (trackMap.isNotEmpty) {
      for (var uri in uris) {
        var tracks = trackMap[uri];
        if (tracks != null && tracks.isNotEmpty) {
          result[uri] = AlbumInfoExtraData(tracks.first);
        }
      }
    }
    return result;
  }

  @override
  Future<List<T>> flatten<T>(List<T> items, {Ref? playlist}) async {
    return waitConnected().then((_) async {
      assert(
          items is List<Ref> || items is List<Track> || items is List<TlTrack>);

      try {
        setBusy(true);
        if (items is List<Ref>) {
          List<Ref> result = List<Ref>.empty(growable: true);
          for (Ref track in (items as List<Ref>)) {
            if (track.type == Ref.typeAlbum ||
                track.type == Ref.typeDirectory) {
              final children = await browse(track);
              final List<Ref> trx = children
                  .map((e) => e.type == Ref.typeTrack ? e : null)
                  .toList()
                  .nonNulls
                  .toList();
              result.addAll(trx);
            } else if (track.type == Ref.typePlaylist) {
              List<Track> children = await getPlaylistItems(track);
              final List<Ref> trx = children.map((e) => e.asRef).toList();
              result.addAll(trx);
            } else if (track.type == Ref.typeTrack) {
              result.add(track);
            }
          }
          return result as List<T>;
        } else {
          return List<T>.from(items);
        }
      } catch (e, s) {
        logger.e(e, stackTrace: s);
      } finally {
        setBusy(false);
      }
      return [];
    });
  }

  @override
  Future<Track?> lookupTrack(Ref track) async {
    assert(track.type == Ref.typeTrack);
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        Map<String,List<Track>> trackMap = await _mopidy.library.lookup([track.uri]);
        if (trackMap.isNotEmpty) {
            var tracks = trackMap[track.uri];
            if (tracks != null && tracks.isNotEmpty) {
              return Future.value(tracks.first);
            }
          }
      } finally {
        setBusy(false);
      }
      return Future.value(null);
    });
  }

  @override
  Future<List<SearchResult>> search(SearchCriteria criteria, {bool exact = false}) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.library.search(criteria, null, exact);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<Map<String, List<MImage>>> getImages(List<String> uris) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.library.getImages(uris);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<List<TlTrack>> getTracklistTlTracks() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.tracklist.getTlTracks();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<List<TlTrack>> addTracksToTracklist<T>(List<T> tracks) async {
    assert(tracks is List<Ref> ||
        tracks is List<Track> ||
        tracks is List<TlTrack>);

    return waitConnected().then((_) {
      try {
        setBusy(true);
        var uris = List<String>.empty(growable: true);
        for (var track in tracks) {
          String uri = getUri(track)!;
          uris.add(uri);
        }
        return _mopidy.tracklist.add(uris, null);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<int> getTracklistLength() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.tracklist.getLength();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> move(int from, int to) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.tracklist.move(from, from, to);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> clearTracklist() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.tracklist.clear();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> deleteFromTracklist(List<int> tlids) async {
    if (tlids.isNotEmpty) {
      return waitConnected().then((_) async {
        try {
          setBusy(true);
          await _mopidy.tracklist
              .remove(FilterCriteria().tlid([...tlids]).toMap());
          return Future.value(null);
        } finally {
          setBusy(false);
        }
      });
    }
    return Future.value(null);
  }

  @override
  Future<List<TlTrack>> addTrackToTracklist<T>(T track) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return addTracksToTracklist([track]);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> playback(PlaybackAction action, int? tlId) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        switch (action) {
          case PlaybackAction.stop:
            return _mopidy.playback.stop();
          case PlaybackAction.play:
            return tlId != null
                ? _mopidy.playback.play(tlId)
                : Future.value(null);
          case PlaybackAction.pause:
            return _mopidy.playback.pause();
          case PlaybackAction.resume:
            return _mopidy.playback.resume();
        }
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> playNext() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.next();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> playPrevious() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.previous();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<TlTrack?> getCurrentTlTrack() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.getCurrentTlTrack();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<int?> getPreviousTlid() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.tracklist.getPreviousTlid();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<int?> getNextTlid() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.tracklist.getNextTlid();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<int> getLastTrackId(Ref track) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        List<TlTrack> tracklist = await getTracklistTlTracks();
        return findIdForTrack(tracklist, track);
      } finally {
        setBusy(false);
      }
    });
  }

  static int findIdForTrack(List<TlTrack> tracklist, Ref track) {
    TlTrack? t = tracklist
        .map((t) => t.track.uri == track.uri ? t : null)
        .nonNulls
        .toList()
        .lastOrNull;
    return t != null ? t.tlid : -1;
  }

  @override
  Future<int?> getTimePosition() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.getTimePosition();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<String> getPlaybackState() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.getState();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<bool> seek(int timePosition) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.seek(timePosition);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<String?> getStreamTitle() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playback.getStreamTitle();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<void> play(Ref track) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        int tlid = await getLastTrackId(track);
        if (tlid == -1) {
          List<TlTrack> tl = await addTrackToTracklist(track);
          tlid = findIdForTrack(tl, track);
        }
        if (tlid != -1) {
          return playback(PlaybackAction.play, tlid);
        }
      } finally {
        setBusy(false);
      }
    });
  }

  // Volume control and muting.

  @override
  Future<bool> isMuted() {
    if (_savedMuteState == null) {
      return waitConnected().then((_) async {
        try {
          setBusy(true);
          _savedMuteState = await _mopidy.mixer.getMute();
          _muteChangedNotifier.value = _savedMuteState!;
          return Future<bool>.value(_savedMuteState);
        } finally {
          setBusy(false);
        }
      });
    } else {
      _savedMuteState = _muteChangedNotifier.value;
      return Future<bool>.value(_savedMuteState);
    }
  }

  @override
  Future<bool> setMute(bool mute) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.mixer.setMute(mute);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<bool> setVolume(int volume) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.mixer.setVolume(volume);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<int> getVolume() {
    if (_savedVolume == null) {
      return waitConnected().then((_) async {
        try {
          setBusy(true);
          _savedVolume = await _mopidy.mixer.getVolume();
          _volumeChangedNotifier.value = _savedVolume!;
          return Future<int>.value(_savedVolume);
        } finally {
          setBusy(false);
        }
      });
    } else {
      _savedVolume = _volumeChangedNotifier.value;
      return Future<int>.value(_savedVolume);
    }
  }

  // Playlists

  @override
  Future<List<Ref>> getPlaylists() {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playlists.asList();
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<List<Track>> getPlaylistItems(Ref playlist) async {
    assert(playlist.type == Ref.typePlaylist);

    return waitConnected().then((_) async {
      try {
        setBusy(true);
        List<Track> result = [];
        Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
        if (pl != null) {
          for (var track in pl.tracks) {
            if (!track.uri.isStreamUri()) {
              Map<String, List<Track>> trackMap =
                  await _mopidy.library.lookup([track.uri]);
              trackMap[track.uri] != null
                  ? result.add(trackMap[track.uri]!.first)
                  : null;
            } else {
              result.add(track);
            }
          }
        }
        return Future.value(result);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<Playlist?> createPlaylist(String name) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        List<Ref> lists = await _mopidy.playlists.asList();
        if (!lists.map((e) => e.name == name).contains(true)) {
          final pl = await _mopidy.playlists.create(name, null);
          lists.add(Ref(pl.uri, pl.name, Ref.typePlaylist));
          await _mopidy.playlists.refresh(null);
          playlistsChangedNotifier.value = lists;
          return Future.value(pl);
        } else {
          return Future.value(null);
        }
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<Playlist?> savePlaylist(Playlist playlist) {
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playlists.save(playlist);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<bool> deletePlaylist(Ref playlist) {
    assert(playlist.type == Ref.typePlaylist);
    return waitConnected().then((_) {
      try {
        setBusy(true);
        return _mopidy.playlists.delete(playlist.uri);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<Playlist?> addToPlaylist<T>(
      BuildContext context, Ref playlist, List<T> items) async {
    assert(
        items is List<Ref> || items is List<Track> || items is List<TlTrack>);
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
        bool trackAdded = false;
        if (pl != null) {
          for (var item in items) {
            if (item is Ref) {
              Track tr =
                  (await _mopidy.library.lookup([item.uri])).values.first[0];
              // Special error handling if this is a stream uri and lookup fails if the stream is invalid
              // or cannot be accessed. Mopidy dart client API sets 'INVALID_STREAM_ERROR' as the name.
              if (tr.name != 'INVALID_STREAM_ERROR') {
                pl.addTrack(tr);
                trackAdded = true;
              } else {
                if (context.mounted) {
                  showError(S.of(context).newStreamAccessError, tr.uri);
                }
              }
            } else if (item is TlTrack) {
              pl.addTrack(item.track);
              trackAdded = true;
            } else {
              pl.addTrack(item as Track);
              trackAdded = true;
            }
          }
          if (trackAdded) {
            Playlist? result = await _mopidy.playlists.save(pl);
            return Future.value(result);
          }
        }
        return Future.value(null);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<Playlist?> movePlaylistItem(Ref playlist, int from, int to) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
        if (pl != null) {
          if (to >= 0 && to < pl.tracks.length) {
            Track t = pl.tracks.removeAt(from);
            pl.tracks.insert(to, t);
            Playlist? result = await _mopidy.playlists.save(pl);
            return Future.value(result);
          }
        }
        return Future.value(null);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<Playlist?> deletePlaylistItems(
      Ref playlist, SelectedItemPositions positions) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
        if (pl != null) {
          var remaining = positions.removeSelected<Track>(pl.tracks);
          pl.tracks.clear();
          pl.tracks.addAll(remaining);
          Playlist? result = await _mopidy.playlists.save(pl);
          return Future.value(result);
        }
        return Future.value(null);
      } finally {
        setBusy(false);
      }
    });
  }

  @override
  Future<bool> renamePlaylist(Ref playlist, String name) async {
    return waitConnected().then((_) async {
      try {
        setBusy(true);
        Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
        if (pl != null) {
          pl.name = name;
          await _mopidy.playlists.save(pl);
          await _mopidy.playlists.delete(pl.uri);
          return true;
        }
        return false;
      } finally {
        setBusy(false);
      }
    });
  }
}

class AlbumInfoExtraData {
  late String uri;
  late String albumName;
  late String artistNames;
  late int? numTracks;
  late String? date;

  AlbumInfoExtraData(Track track) {
    if (track.album != null) {
      Album album = track.album!;
      uri = track.uri;
      artistNames = track.artistNames ?? "";
      numTracks = album.numTracks;
      date = album.date;
      albumName = album.name;
    }
  }
}
