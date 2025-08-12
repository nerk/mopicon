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
import 'package:mopidy_client/mopidy_client.dart' hide Image;
import 'package:mopicon/extensions/mopidy_utils.dart';

var _audioFormats = <String>[
  '.mp3',
  '.ogg',
  '.wav',
  '.aac',
  '.aiff',
  '.m4a',
  '.flac'
];

class ImageUtils {
  static const double defaultThumbnailSize = 100.0;
  static const double defaultCoverSize = 100.0;

  static Widget getIconForType(String? uri, [double? size]) {
    if (uri != null) {
      var iconData = defaultIconData(uri);
      return FittedBox(
          child: Icon(iconData));
    } else {
      return FittedBox(child: Icon(Icons.question_mark));
    }
  }

  static Widget pad(dynamic image, double size) {
    return Padding(padding: EdgeInsets.all(size), child: image);
  }

  static Widget roundedCornersWithPadding(dynamic image, double width, double height) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10), // Image border
            child: SizedBox.fromSize(
                size: Size(width, height), // Image radius
                child: image)));
  }

  static Widget resize(image, double width, double height) {
    return SizedBox.fromSize(
        size: Size(width, height), // Image radius
        child: image);
  }

  static IconData? defaultIconData(String uri, [double? size]) {
    if (uri.startsWith('local:directory')) {
      if (uri.startsWith('local:directory?type=album')) {
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
    var suffix = _getExtension(uri);
    return _audioFormats.contains(suffix);
  }

  static String _getExtension(String uri) {
    var idx = uri.lastIndexOf('.');
    if (idx != -1) {
      return uri.substring(idx);
    }
    return "";
  }
}
