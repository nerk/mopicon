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
import 'package:mopicon/utils/globals.dart';

Future<String?> renamePlaylistDialog(String currentName) {
  final modalDialogKey =
      GlobalKey<FormState>(debugLabel: "renamePlaylistDialog");
  String newName = '';

  return showDialog<String>(
    context: Globals
        .applicationRoutes.rootNavigatorKey.currentState!.overlay!.context,
    builder: (BuildContext context) {
      return ModalDialog(
        Text(S.of(context).renamePlaylistDialogTitle),
        Form(
            key: modalDialogKey,
            child: TextFormField(
              keyboardType: TextInputType.text,
              initialValue: currentName,
              autocorrect: false,
              decoration: InputDecoration(
                  icon: const Icon(Icons.drive_file_rename_outline),
                  hintText: S.of(context).renamePlaylistDialogNameHint,
                  labelText: S.of(context).renamePlaylistDialogNameLabel),
              onChanged: (String value) {
                newName = value;
              },
              validator: (String? value) {
                return value != null && value.isNotEmpty
                    ? null
                    : S.of(context).playlistNameInvalidError;
              },
              maxLength: 30,
            )),
        <Widget>[
          DialogButton.oK(context, onPressed: () {
            if (modalDialogKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(newName);
            }
          }),
          DialogButton.cancel(context)
        ],
        defaultActionIndex: 0,
      );
    },
  );
}
