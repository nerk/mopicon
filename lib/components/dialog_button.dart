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

/// Common buttons used in dialogs
class DialogButton {
  static Widget yes(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).yesBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget no(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).noBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget oK(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).okBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget cancel(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).cancelBtn,
        onPressed: onPressed ??
            () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
        autoFocus: autoFocus);
  }

  static Widget retry(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).retryBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget abort(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).abortBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget submit(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).submitBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget save(BuildContext context,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return button(context, S.of(context).saveBtn,
        onPressed: onPressed, autoFocus: autoFocus);
  }

  static Widget button(BuildContext context, String label,
      {VoidCallback? onPressed, bool? autoFocus}) {
    return ElevatedButton(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        onPressed: onPressed,
        autofocus: autoFocus ?? false,
        child: Text(label));
  }
}
