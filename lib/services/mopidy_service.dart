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

import 'package:flutter/material.dart' show BuildContext, ValueNotifier;
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopidy_client/mopidy_client.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mopicon/common/globals.dart';
export 'package:mopidy_client/mopidy_client.dart' hide Image;
import 'package:mopicon/generated/l10n.dart';

/// Enum to control playback of a track.
enum PlaybackAction { stop, pause, play, resume }

enum MopidyConnectionState { online, offline, reconnecting }

/// Access layer to Mopidy
abstract class MopidyService {
  /// Notification about current connection state.
  Stream<MopidyConnectionState> get connectionState$;

  /// Notifier if items were added or removed from the tracklist.
  ValueNotifier<List<TlTrack>> get tracklistChangedNotifier;

  /// Notifiers about playback state of a track
  ValueNotifier<TrackPlaybackInfo?> get trackPlaybackNotifier;

  ValueNotifier<PlaybackState?> get playbackStateNotifier;

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

  void stop();

  bool get connected;

  bool get stopped;

  // List of URI schemes supported by the server
  Future<List<String>> getUriSchemes();

  //
  // Library browser.
  //
  Future<List<Ref>> browse(Ref? parent);

  Future<List<SearchResult>> search(SearchCriteria criteria);

  Future<Map<String, List<Image>>> getImages(List<String> albumUris);

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

  Future<Playlist?> addToPlaylist<T>(BuildContext context, Ref playlist, List<T> items);

  Future<void> movePlaylistItem(Ref playlist, int from, int to);

  Future<Playlist?> deletePlaylistItems(Ref playlist, SelectedItemPositions positions);

  Future<bool> renamePlaylist(Ref playlist, String name);

  // Mixer
  Future<bool> setMute(bool mute);

  Future<bool?> isMuted();

  Future<bool> setVolume(int volume);

  Future<int?> getVolume();
}

class MopidyServiceImpl extends MopidyService {
  /// Notification about current connection state.
  final _connectionState$ = PublishSubject<MopidyConnectionState>();

  /// Notifier if items were added or removed from the tracklist.
  final _tracklistChangedNotifier = ValueNotifier<List<TlTrack>>([]);

  /// Notifiers about playback state of a track
  final _trackPlaybackNotifier = ValueNotifier<TrackPlaybackInfo?>(null);
  final _playbackStateNotifier = ValueNotifier<PlaybackState?>(null);

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

  @override
  Stream<MopidyConnectionState> get connectionState$ => _connectionState$.stream;

  @override
  ValueNotifier<List<TlTrack>> get tracklistChangedNotifier => _tracklistChangedNotifier;

  @override
  ValueNotifier<TrackPlaybackInfo?> get trackPlaybackNotifier => _trackPlaybackNotifier;

  @override
  ValueNotifier<PlaybackState?> get playbackStateNotifier => _playbackStateNotifier;

  @override
  ValueNotifier<bool> get muteChangedNotifier => _muteChangedNotifier;

  @override
  ValueNotifier<int> get volumeChangedNotifier => _volumeChangedNotifier;

  @override
  ValueNotifier<String?> get streamTitleChangedNotifier => _streamTitleChangedNotifier;

  @override
  ValueNotifier<List<Ref>> get playlistsChangedNotifier => _playlistsChangedNotifier;

  @override
  ValueNotifier<Playlist?> get playlistChangedNotifier => _playlistChangedNotifier;

  final Mopidy _mopidy;

  bool _connected = false;
  bool _stopped = false;

  MopidyServiceImpl() : _mopidy = Mopidy(logger: Globals.logger, backoffDelayMin: 500, backoffDelayMax: 2000) {
    /*
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == 'AppLifecycleState.resumed') {
        if (_lastConnectedUri == _currentUri) {
          print("RESUMED");
          Globals.logger.i("Reonnecting to $_lastConnectedUri");
          connect(_currentUri);
        }
      }
      return Future.value(null);
    });
*/
    _mopidy.clientState$.listen((value) {
      _connected = false;
      switch (value.state) {
        case ClientState.online:
          _stopped = false;
          _connected = true;
          _connectionState$.add(MopidyConnectionState.online);
          break;
        case ClientState.offline:
          _connectionState$.add(MopidyConnectionState.offline);
          break;
        case ClientState.reconnecting:
          _connectionState$.add(MopidyConnectionState.reconnecting);
          break;
        default:
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
  Future<List<String>> getUriSchemes() {
    return _mopidy.getUriSchemes();
  }

  @override
  bool get stopped => _stopped;

  @override
  Future<bool> connect(String uri, {int? maxRetries}) async {
    _mopidy.disconnect();
    _connected = false;
    Globals.logger.i("Connecting to $uri");
    return await _mopidy.connect(webSocketUrl: uri, maxRetries: maxRetries);
  }

  @override
  void stop() {
    _connected = false;
    _stopped = true;
    _mopidy.disconnect();
  }

  @override
  bool get connected => _connected;

  @override
  Future<List<Ref>> browse(Ref? parent) async {
    var refs = await _mopidy.library.browse(parent?.uri);
    // lookup and add album extra info
    List<String> uris = refs.map((e) => e.type == Ref.typeAlbum ? e.uri : null).nonNulls.toList();

    if (uris.isNotEmpty) {
      Map<String, List<Track>> trackMap = await _mopidy.library.lookup(uris);
      if (trackMap.isNotEmpty) {
        for (var ref in refs) {
          var tracks = trackMap[ref.uri];
          if (tracks != null && tracks.isNotEmpty) {
            Album? album = tracks.first.album;
            if (album != null) {
              ref.extraData = AlbumInfoExtraData(album);
            }
          }
        }
      }
    }
    return refs;
  }

  @override
  Future<List<T>> flatten<T>(List<T> items, {Ref? playlist}) async {
    assert(items is List<Ref> || items is List<Track> || items is List<TlTrack>);

    try {
      if (items is List<Ref>) {
        List<Ref> result = List<Ref>.empty(growable: true);
        for (Ref track in (items as List<Ref>)) {
          if (track.type == Ref.typeAlbum || track.type == Ref.typeDirectory) {
            final children = await browse(track);
            final List<Ref> trx = children.map((e) => e.type == Ref.typeTrack ? e : null).toList().nonNulls.toList();
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
      } else if (items is List<Track>) {
        List<Track> result = List<Track>.empty(growable: true);
        result.addAll(items as List<Track>);
        return result as List<T>;
      } else {
        List<TlTrack> result = List<TlTrack>.empty(growable: true);
        result.addAll(items as List<TlTrack>);
        return result as List<T>;
      }
    } catch (e, s) {
      Globals.logger.e(e, stackTrace: s);
    }
    return [];
  }

  @override
  Future<List<SearchResult>> search(SearchCriteria criteria) {
    return _mopidy.library.search(criteria, null, false);
  }

  @override
  Future<Map<String, List<Image>>> getImages(List<String> albumUris) {
    return _mopidy.library.getImages(albumUris);
  }

  @override
  Future<List<TlTrack>> getTracklistTlTracks() {
    return _mopidy.tracklist.getTlTracks();
  }

  @override
  Future<List<TlTrack>> addTracksToTracklist<T>(List<T> tracks) async {
    assert(tracks is List<Ref> || tracks is List<Track> || tracks is List<TlTrack>);

    var uris = List<String>.empty(growable: true);
    for (var track in tracks) {
      String uri = getUri(track)!;
      uris.add(uri);
    }
    return _mopidy.tracklist.add(uris, null);
  }

  @override
  Future<int> getTracklistLength() {
    return _mopidy.tracklist.getLength();
  }

  @override
  Future<void> move(int from, int to) {
    return _mopidy.tracklist.move(from, from, to);
  }

  @override
  Future<void> clearTracklist() {
    return _mopidy.tracklist.clear();
  }

  @override
  Future<void> deleteFromTracklist(List<int> tlids) async {
    if (tlids.isNotEmpty) {
      await _mopidy.tracklist.remove(FilterCriteria().tlid([...tlids]).toMap());
    }
    return Future.value(null);
  }

  @override
  Future<List<TlTrack>> addTrackToTracklist<T>(T track) {
    return addTracksToTracklist([track]);
  }

  @override
  Future<void> playback(PlaybackAction action, int? tlId) {
    switch (action) {
      case PlaybackAction.stop:
        return _mopidy.playback.stop();
      case PlaybackAction.play:
        return tlId != null ? _mopidy.playback.play(tlId) : Future.value(null);
      case PlaybackAction.pause:
        return _mopidy.playback.pause();
      case PlaybackAction.resume:
        return _mopidy.playback.resume();
    }
  }

  @override
  Future<void> playNext() {
    return _mopidy.playback.next();
  }

  @override
  Future<void> playPrevious() {
    return _mopidy.playback.previous();
  }

  @override
  Future<TlTrack?> getCurrentTlTrack() {
    return _mopidy.playback.getCurrentTlTrack();
  }

  @override
  Future<int?> getPreviousTlid() {
    return _mopidy.tracklist.getPreviousTlid();
  }

  @override
  Future<int?> getNextTlid() {
    return _mopidy.tracklist.getNextTlid();
  }

  @override
  Future<int> getLastTrackId(Ref track) async {
    List<TlTrack> tracklist = await getTracklistTlTracks();
    return findIdForTrack(tracklist, track);
  }

  static int findIdForTrack(List<TlTrack> tracklist, Ref track) {
    TlTrack? t = tracklist.map((t) => t.track.uri == track.uri ? t : null).nonNulls.toList().lastOrNull;
    return t != null ? t.tlid : -1;
  }

  @override
  Future<int?> getTimePosition() {
    return _mopidy.playback.getTimePosition();
  }

  @override
  Future<String> getPlaybackState() {
    return _mopidy.playback.getState();
  }

  @override
  Future<bool> seek(int timePosition) {
    return _mopidy.playback.seek(timePosition);
  }

  @override
  Future<String?> getStreamTitle() {
    return _mopidy.playback.getStreamTitle();
  }

  @override
  Future<void> play(Ref track) async {
    int tlid = await getLastTrackId(track);
    if (tlid == -1) {
      List<TlTrack> tl = await addTrackToTracklist(track);
      tlid = findIdForTrack(tl, track);
    }
    if (tlid != -1) {
      return playback(PlaybackAction.play, tlid);
    }
  }

  // Volume control and muting.

  @override
  Future<bool?> isMuted() {
    return _mopidy.mixer.getMute();
  }

  @override
  Future<bool> setMute(bool mute) {
    return _mopidy.mixer.setMute(mute);
  }

  @override
  Future<bool> setVolume(int volume) {
    return _mopidy.mixer.setVolume(volume);
  }

  @override
  Future<int?> getVolume() {
    return _mopidy.mixer.getVolume();
  }

  // Playlists

  @override
  Future<List<Ref>> getPlaylists() {
    return _mopidy.playlists.asList();
  }

  @override
  Future<List<Track>> getPlaylistItems(Ref playlist) async {
    assert(playlist.type == Ref.typePlaylist);

    List<Track> result = [];
    Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
    if (pl != null) {
      for (var track in pl.tracks) {
        if (!track.uri.isStreamUri()) {
          Map<String, List<Track>> trackMap = await _mopidy.library.lookup([track.uri]);
          trackMap[track.uri] != null ? result.add(trackMap[track.uri]!.first) : null;
        } else {
          result.add(track);
        }
      }
    }
    return Future.value(result);
  }

  @override
  Future<Playlist?> createPlaylist(String name) async {
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
  }

  @override
  Future<Playlist?> savePlaylist(Playlist playlist) {
    return _mopidy.playlists.save(playlist);
  }

  @override
  Future<bool> deletePlaylist(Ref playlist) {
    assert(playlist.type == Ref.typePlaylist);
    return _mopidy.playlists.delete(playlist.uri);
  }

  @override
  Future<Playlist?> addToPlaylist<T>(BuildContext context, Ref playlist, List<T> items) async {
    assert(items is List<Ref> || items is List<Track> || items is List<TlTrack>);
    Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
    bool trackAdded = false;
    if (pl != null) {
      for (var item in items) {
        if (item is Ref) {
          Track tr = (await _mopidy.library.lookup([item.uri])).values.first[0];
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
  }

  @override
  Future<Playlist?> movePlaylistItem(Ref playlist, int from, int to) async {
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
  }

  @override
  Future<Playlist?> deletePlaylistItems(Ref playlist, SelectedItemPositions positions) async {
    Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
    if (pl != null) {
      var remaining = positions.removeSelected<Track>(pl.tracks);
      pl.tracks.clear();
      pl.tracks.addAll(remaining);
      Playlist? result = await _mopidy.playlists.save(pl);
      return Future.value(result);
    }
    return Future.value(null);
  }

  @override
  Future<bool> renamePlaylist(Ref playlist, String name) async {
    Playlist? pl = await _mopidy.playlists.lookup(playlist.uri);
    if (pl != null) {
      pl.name = name;
      await _mopidy.playlists.save(pl);
      await _mopidy.playlists.delete(pl.uri);
      return true;
    }
    return false;
  }
}

class AlbumInfoExtraData {
  late String albumName;
  late String artistNames;
  late int? numTracks;
  late String? date;

  AlbumInfoExtraData(Album album) {
    artistNames = album.artists.map((artist) => artist.name).toList().join(', ');
    numTracks = album.numTracks;
    date = album.date;
    albumName = album.name;
  }
}
