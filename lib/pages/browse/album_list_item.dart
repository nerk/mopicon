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
import 'package:mopicon/pages/browse/library_browser_controller.dart';
import 'package:mopidy_client/mopidy_client.dart' hide Image;
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/utils/globals.dart';

class AlbumListItem extends StatelessWidget {
  final _controller = GetIt.instance<LibraryBrowserController>();

  final Ref albumRef;
  final Widget thumbnail;
  final String title;
  final String artist;
  final String? date;
  final int? numTracks;
  final void Function()? onTap;

  AlbumListItem(this.albumRef, this.thumbnail, this.title, this.artist,
      this.numTracks, this.date, this.onTap,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            thumbnail,
            Expanded(
              child: _AlbumDescription(title, artist, numTracks, date),
            ),
            _controller
                .popupMenu(context, albumRef, null)
                .build(context, albumRef, null)
          ],
        ),
      ),
    );
  }
}

class _AlbumDescription extends StatelessWidget {
  final String title;
  final String artist;
  final int? numTracks;
  final String? date;

  const _AlbumDescription(this.title, this.artist, this.numTracks, this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            artist,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          numTracks != null
              ? Text('$numTracks Tracks',
                  style: const TextStyle(fontSize: 10.0))
              : const SizedBox(),
          date != null
              ? Text(S.of(Globals.rootContext).albumDateLbl(date!))
              : const SizedBox(),
        ],
      ),
    );
  }
}
