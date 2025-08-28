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
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/logging_utils.dart';

mixin TracklistMethods {
  final _mopidyService = GetIt.instance<MopidyService>();

  /// Adds items to tracklist.
  ///
  /// Adds all [items] to the tracklist and returns the resulting added
  /// [TlTrack] objects. If an item on [items] has children, add its children
  /// instead of the item itself.
  Future<List<TlTrack>> addItemsToTracklist(BuildContext context, List<Ref> items) async {

    List<Ref> flattened = await _mopidyService.flatten<Ref>(items);
    var tl = <TlTrack>[];
    try {
      tl = await _mopidyService.addTracksToTracklist(flattened);
    } catch (e, s) {
      logger.e(e, stackTrace: s);
    } finally {
      if (context.mounted) {
        if (tl.length > 1) {
          showInfo(S.of(context).tracksAddedToTracklistMessage(tl.length), null);
        } else {
          showInfo(S.of(context).trackAddedToTracklistMessage, null);
        }
      }
    }
    return tl;
  }
}
