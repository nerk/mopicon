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

var _iconMap = <String, IconData>{
  Ref.typeDirectory: Icons.folder,
  Ref.typeAlbum: Icons.album,
  Ref.typeArtist: Icons.person,
  Ref.typeTrack: Icons.web_asset,
  Ref.typePlaylist: Icons.list,
  'stream': Icons.radio
};

class ImageUtils {
  static const double defaultThumbnailSize = 40.0;
  static const double defaultCoverSize = 100.0;

  static get noIcon => const Icon(null, size: defaultThumbnailSize);

  static Icon getIconForType(String? uri, String type, [double? size]) {
    return Icon(_iconMap[_computeType(uri, type)], size: size ?? defaultThumbnailSize);
  }

  static String _computeType(String? uri, String type) {
    if (uri != null) {
      if (type == Ref.typeDirectory) {
        if (uri.contains('?type=album') || uri.contains('&album=local:album')) {
          type = Ref.typeAlbum;
        } else if (uri.contains('?type=artist') || uri.contains('?composer=local:artist')) {
          type = Ref.typeArtist;
        }
      } else if (type == Ref.typeTrack && uri.isStreamUri()) {
        type = "stream";
      }
    }
    return type;
  }

  static Widget pad(image, double size) {
    return Padding(padding: EdgeInsets.all(size), child: image);
  }

  static Widget roundedCornersWithPadding(image, double width, double height) {
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
}
