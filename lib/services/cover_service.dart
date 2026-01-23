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
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/utils/cache.dart';
import 'package:mopicon/utils/logging_utils.dart';

import 'mopidy_service.dart';

abstract class CoverService {
  static const double defaultThumbnailSize = 100.0;
  static const double defaultCoverSize = 100.0;

  Future<Widget?> getImage(String uri);

  Future<Map<String, Widget?>> getImages(List<String> uris);
}

class CoverServiceImpl extends CoverService {
  final _mopidyService = GetIt.instance<MopidyService>();
  final _preferences = GetIt.instance<PreferencesController>();

  // cache for images
  final _imageCache = Cache<Widget>(2000, 5000);

  @override
  Future<Widget?> getImage(String? uri) async {
    if (uri == null) {
      return const Icon(Icons.question_mark);
    }
    return Future<Widget>.value((await getImages([uri]))[uri]);
  }

  @override
  Future<Map<String, Widget?>> getImages(List<String> uris) async {
    if (uris.isEmpty) {
      return {};
    }

    var cacheMisses = List<String>.empty(growable: true);
    var covers = <String, Widget?>{};
    for (var uri in uris) {
      var cover = _imageCache.get(uri);
      if (cover != null) {
        covers[uri] = cover;
      } else {
        cacheMisses.add(uri);
      }
    }

    if (cacheMisses.isNotEmpty) {
      try {
        Map<String, List<MImage>> images = await _mopidyService.getImages(cacheMisses);
        for (var uri in images.keys) {
          Image? img;
          MImage? mImage;
          if (images[uri] != null && images[uri]!.isNotEmpty) {
            mImage = images[uri]!.first;
          }

          if (mImage != null) {
            img = Image.network(
              _preferences.computeNetworkUrl(mImage),
              errorBuilder: (BuildContext context, Object obj, StackTrace? st) {
                logger.e(obj.toString());
                return getIconForType(uri);
              },
            );
            covers[uri] = FittedBox(fit: BoxFit.cover, child: img);
            _imageCache.put(uri, covers[uri]!);
          } else {
            covers[uri] = FittedBox(fit: BoxFit.cover, child: getIconForType(uri));
          }
        }
      } catch (e, s) {
        logger.e(e, stackTrace: s);
      }
    }
    return Future.value(covers);
  }

  static Widget getIconForType(String? uri, [double? size]) {
    if (uri != null) {
      return Icon(defaultIconData(uri));
    } else {
      return Icon(Icons.question_mark);
    }
  }

  static IconData? defaultIconData(String uri, [double? size]) {
    if (uri.startsWith('local:directory')) {
      if (uri.startsWith('local:directory?type=album') || uri.startsWith('local:directory?type=track&album=')) {
        return Icons.album;
      } else if (uri.startsWith('local:directory?type=artist')) {
        return Icons.person;
      } else if (uri.startsWith('local:directory?type=artist&role=performer')) {
        return Icons.person;
      } else if (uri.startsWith('local:directory?type=artist&role=composer')) {
        return Icons.person;
      } else if (uri.startsWith('local:directory?type=genre')) {
        return Icons.folder;
      } else if (uri.startsWith('local:directory?type=track')) {
        return Icons.list;
      } else if (uri.startsWith('local:directory?type=date&format=%25Y')) {
        // Release years
        return Icons.folder;
      } else if (uri.startsWith('local:directory?max-age=604800')) {
        // week updates
        return Icons.folder;
      } else if (uri.startsWith('local:directory?max-age=2592000')) {
        //  month's updates
        return Icons.folder;
      }
      return Icons.folder;
    } else if (uri.startsWith('podcast+')) {
      return Icons.podcasts;
    } else if (uri.startsWith('tunein:root')) {
      return Icons.radio;
    } else if (uri.startsWith('m3u:')) {
      return Icons.list;
    } else if (uri.startsWith('dleyna:')) {
      return Icons.computer;
    } else if (uri.startsWith('bookmark:')) {
      return Icons.featured_play_list;
    } else if (uri.startsWith('local:album:')) {
      return Icons.album;
    } else if (uri.startsWith('local:artist:')) {
      return Icons.person;
    } else if (uri.startsWith('local:track:')) {
      return Icons.audiotrack;
    } else if (uri.startsWith('file:///')) {
      if (_isAudioFile(uri)) {
        return Icons.audio_file;
      } else {
        return Icons.folder;
      }
    } else if (uri.isStreamUri()) {
      return Icons.radio;
    }
    return null;
  }

  static bool _isAudioFile(String uri) {
    const audioFormats = <String>['.mp3', '.ogg', '.wav', '.aac', '.aiff', '.m4a', '.mp4a', '.mp4', '.flac'];

    var suffix = _getExtension(uri);
    return audioFormats.contains(suffix);
  }

  static String _getExtension(String uri) {
    var idx = uri.lastIndexOf('.');
    if (idx != -1) {
      return uri.substring(idx);
    }
    return "";
  }
}
