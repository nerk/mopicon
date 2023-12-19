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
import 'package:mopicon/components/dialog_button.dart';
import 'package:mopicon/utils/globals.dart';

/// Confirmation options for question dialogs.
enum DialogButtonOption { yes, no, ok, cancel, retry, abort, submit, save }

/// Show a modal question dialog with [title], [message], and a list of [buttons].
/// If [defaultOption] is provided, the corresponding button gets the autofocus.
/// Upon closing, either the pressed dialog option is returned or `null` if
/// no button was pressed.
Future<DialogButtonOption?> showQuestionDialog(
    String title, String message, List<DialogButtonOption> buttons,
    {DialogButtonOption? defaultOption}) {
  return showDialog<DialogButtonOption>(
    context: Globals
        .applicationRoutes.rootNavigatorKey.currentState!.overlay!.context,
    builder: (BuildContext context) {
      var actions = List<Widget>.empty(growable: true);
      for (var button in buttons) {
        switch (button) {
          case DialogButtonOption.yes:
            actions.add(DialogButton.yes(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.yes);
            }, autoFocus: defaultOption == DialogButtonOption.yes));
            break;
          case DialogButtonOption.no:
            actions.add(DialogButton.no(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.no);
            }, autoFocus: defaultOption == DialogButtonOption.no));
            break;
          case DialogButtonOption.ok:
            actions.add(DialogButton.oK(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.ok);
            }, autoFocus: defaultOption == DialogButtonOption.ok));
            break;
          case DialogButtonOption.cancel:
            actions.add(DialogButton.cancel(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.cancel);
            }, autoFocus: defaultOption == DialogButtonOption.cancel));
            break;
          case DialogButtonOption.retry:
            actions.add(DialogButton.retry(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.retry);
            }, autoFocus: defaultOption == DialogButtonOption.retry));
            break;
          case DialogButtonOption.abort:
            actions.add(DialogButton.abort(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.abort);
            }, autoFocus: defaultOption == DialogButtonOption.abort));
            break;
          case DialogButtonOption.submit:
            actions.add(DialogButton.submit(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.submit);
            }, autoFocus: defaultOption == DialogButtonOption.submit));
            break;
          case DialogButtonOption.save:
            actions.add(DialogButton.save(context, onPressed: () {
              Navigator.of(context).pop(DialogButtonOption.save);
            }, autoFocus: defaultOption == DialogButtonOption.save));
            break;
        }
      }

      return AlertDialog(
          title: Text(title), content: Text(message), actions: actions);
    },
  );
}
