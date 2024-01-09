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
import 'mopidy_service.dart';
import 'package:mopicon/utils/cache.dart';
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/services/preferences_service.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';

abstract class CoverService {
  static final defaultImage = Image.asset('assets/album_default.png');

  Future<Widget> getImage(String uri);
}

class CoverServiceImpl extends CoverService {
  final _mopidyService = GetIt.instance<MopidyService>();
  final _preferences = GetIt.instance<Preferences>();

  // cache Image objects returned from mopidy.
  final _mImages = Cache<MImage>(500, 3000);

  @override
  Future<Widget> getImage(String uri) async {
    Widget? image = await _getImage(uri);
    if (image != null) {
      return Future.value(ImageUtils.pad(image, 3));
    } else if (uri.isStreamUri()) {
      return Future.value(ImageUtils.pad(ImageUtils.getIconForType(uri, Ref.typeTrack), 3));
    }
    return Future.value(ImageUtils.pad(CoverService.defaultImage, 3));
  }

  Future<Widget?> _getImage(String? uri) async {
    if (uri != null) {
      var mImage = _mImages.get(uri);
      if (mImage == null) {
        Map<String, List<MImage>> images = await _mopidyService.getImages([uri]);
        if (images[uri] != null && images[uri]!.isNotEmpty) {
          mImage = images[uri]!.first;
          _mImages.put(uri, mImage);
        }
      }
      if (mImage != null) {
        // images loaded from network are internally cached
        Image img = Image.network(_preferences.computeNetworkUrl(mImage));
        return Future.value(img);
      }
    }
    return Future.value(null);
  }
}
