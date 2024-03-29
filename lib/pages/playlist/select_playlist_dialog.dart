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
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/components/dialog_button.dart';
import 'package:mopicon/components/modal_dialog.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/common/globals.dart';

Future<Ref?> selectPlaylistDialog(List<Ref> playlists) {
  final modalDialogKey = GlobalKey<FormState>(debugLabel: "selectPlaylistDialog");
  Ref? playlist;

  return showDialog<Ref>(
    context: Globals.applicationRoutes.rootNavigatorKey.currentState!.overlay!.context,
    builder: (BuildContext ctx1) {
      return ModalDialog(
        constrainSize: true,
        Text(S.of(ctx1).selectPlaylistDialogTitle),
        Form(
            key: modalDialogKey,
            child: ListView.builder(
                //itemExtent: 160.0,
                itemCount: playlists.length,
                itemBuilder: (BuildContext ctx2, int index) => ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        if (ctx2.mounted) {
                          Navigator.of(ctx2).pop(playlists[index]);
                        }
                      },
                      title: Text(playlists[index].name),
                    ))),
        <Widget>[
          DialogButton.oK(ctx1, onPressed: () {
            //if (modalDialogKey.currentState?.validate() ?? false) {
            if (ctx1.mounted) {
              Navigator.of(ctx1).pop(playlist);
            }
            //}
          }),
          DialogButton.cancel(ctx1)
        ],
        defaultActionIndex: 0,
      );
    },
  );
}
