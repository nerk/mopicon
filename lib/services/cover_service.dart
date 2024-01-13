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
import 'package:mopicon/utils/logging_utils.dart';
import 'mopidy_service.dart';
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';

abstract class CoverService {
  static final defaultImage = Image.asset('assets/album_default.png');

  Future<Widget> getImage(String uri);
}

class CoverServiceImpl extends CoverService {
  final _mopidyService = GetIt.instance<MopidyService>();
  final _preferences = GetIt.instance<PreferencesController>();

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
      try {
        var mImage = ImageUtils.noIcon;
        Map<String, List<MImage>> images = await _mopidyService.getImages([uri]);
        if (images[uri] != null && images[uri]!.isNotEmpty) {
          mImage = images[uri]!.first;
        }
        Image img = Image.network(
          _preferences.computeNetworkUrl(mImage),
          errorBuilder: (BuildContext context, Object obj, StackTrace? st) {
            logger.e(obj.toString());
            return ImageUtils.noIcon;
          },
        );
        return Future.value(img);
      } catch (e, s) {
        logger.e(e, stackTrace: s);
      }
    }
    return Future.value(null);
  }
}
