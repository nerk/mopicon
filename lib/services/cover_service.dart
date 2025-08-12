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
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/utils/cache.dart';
import 'mopidy_service.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';

abstract class CoverService {

  Future<Widget?> getImage(String uri);

  Future<Map<String, Widget?>> getImages(List<String> uris);
}

class CoverServiceImpl extends CoverService {
  final _mopidyService = GetIt.instance<MopidyService>();
  final _preferences = GetIt.instance<PreferencesController>();

  // cache for the
  final _coverImages = Cache<Widget>(2000, 5000);

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
      var cover = _coverImages.get(uri);
      if (cover != null) {
        covers[uri] = cover;
      } else {
        cacheMisses.add(uri);
      }
    }

    if (cacheMisses.isNotEmpty) {
      try {
        Map<String, List<MImage>> images =
        await _mopidyService.getImages(cacheMisses);
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
                return const Icon(Icons.question_mark);
              },
            );
            _coverImages.put(uri, img);
            covers[uri] = img;
          } else {
            var img = ImageUtils.getIconForType(uri);
            _coverImages.put(uri, img);
            covers[uri] = img;
          }
        }
      } catch (e, s) {
        logger.e(e, stackTrace: s);
      }
    }
    return Future.value(covers);
  }
}
