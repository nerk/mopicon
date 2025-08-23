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

import 'package:mopicon/services/mopidy_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/services/cover_service.dart';

final _coverService = GetIt.instance<CoverService>();

/// Tests if a string represents a stream URI.
extension MopiStringExtensions on String {
  bool isStreamUri() {
    return ['http:', 'https:', 'mms:', 'rtmp:', 'rtmps:', 'rtsp:', 'tunein', 'podcast']
        .map((e) => startsWith(e) ? true : null)
        .nonNulls
        .toList()
        .isNotEmpty;
  }

  bool isPodcastUri() {
    return startsWith('podcast');
  }
}

extension MopidyRefExtensions on Ref {

  String getUri() {
    return uri;
  }

  String getName() {
    return name;
  }

  /// Returns the image for [Ref]
  Future<Widget?> getImage() async {
    return _coverService.getImage(uri);
  }

  /// Returns a comma separated string of artists.
  String? get artistNames {
    if (extraData != null) {
      return (extraData as AlbumInfoExtraData).artistNames;
    }
    return null;
  }

  /// Returns the name of an album.
  String? get albumName {
    if (extraData != null) {
      return (extraData as AlbumInfoExtraData).albumName;
    }
    return null;
  }

  /// Returns the URI of an album.
  String? get albumUri {
    if (extraData != null) {
      return (extraData as AlbumInfoExtraData).uri;
    }
    return null;
  }
}

extension MopidyRefListExtensions on List<Ref> {
  /// Returns the images for [List<Ref>]
  Future<Map<String, Widget?>> getImages() async {
    return _coverService.getImages(map((e) => e.uri).toList());
  }
}

extension MopidyTrackListExtensions on List<Track> {
  /// Returns the images for [List<Track>]
  Future<Map<String, Widget?>> getImages() async {
    return _coverService.getImages(map((e) => e.uri).toList());
  }
}

extension MopidyTlTrackListExtensions on List<TlTrack> {
  /// Returns the images for [List<TlTrack>]
  Future<Map<String, Widget?>> getImages() async {
    return _coverService.getImages(map((e) => e.track.uri).toList());
  }
}

extension MopidyTrackExtensions on Track {

  String getName() {
    return name;
  }

  String getUri() {
    return uri;
  }

  /// Returns the image for [Track]
  Future<Widget?> getImage() async {
    return _coverService.getImage(uri);
  }

  /// Returns a comma separated string of artists.
  String? get artistNames {
    String? albumArtists;
    if (album != null) {
      albumArtists = album!.artists.map((artist) => artist.name).toList().join(', ');
      if (albumArtists.isEmpty) {
        albumArtists = artists.map((artist) => artist.name).toList().join(', ');
      }
    }
    return albumArtists;
  }

  /// Converts a [Track] into a [Ref],
  Ref get asRef {
    return Ref(uri, name, Ref.typeTrack);
  }
}

extension MopidyTlTrackExtensions on TlTrack {

  String getUri() {
    return track.uri;
  }

  String getName() {
    return track.name;
  }

  /// Converts a [TlTrack] into a [Ref],
  Ref get asRef {
    return Ref(track.uri, track.name, Ref.typeTrack);
  }
}

extension TracklistExtensions on List<Track> {
  /// Converts a a List of [Track]s into a List of [Ref]s,
  List<Ref> get asRef {
    return List.generate(length, (index) {
      return Ref(this[index].uri, this[index].name, Ref.typeTrack);
    });
  }
}

extension TlTracklistExtensions on List<TlTrack> {
  /// Converts a a List of [TlTrack]s into a List of [Ref]s,
  List<Ref> get asRef {
    return List.generate(length, (index) {
      return Ref(this[index].track.uri, this[index].track.name, Ref.typeTrack);
    });
  }
}

String? getUri(dynamic obj) {
  if (obj is Ref || obj is Track) {
    return obj.uri;
  } else if (obj is TlTrack) {
    return obj.track.uri;
  }
  return null;
}
