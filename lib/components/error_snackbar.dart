/*
 * Copyright (c) 2024 Thomas Kern
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
import 'package:muelli/common/globals.dart';
import 'package:muelli/pages/preferences/preferences_controller.dart';

/// Displays a [SnackBar] with error icon, [title] and [detail].
void showError(String title, String? detail) {
  Globals.rootScaffoldMessengerKey.currentState!
      .showSnackBar(_ErrorSnackBar(title: title, detail: detail));
}

/// Displays a [SnackBar] with info icon, [title] and [detail].
void showInfo(String title, String? detail) {
  Globals.rootScaffoldMessengerKey.currentState!
      .showSnackBar(_InfoSnackBar(title: title, detail: detail));
}

/// Closes the current [SnackBar].
void closeSnackBar() {
  Globals.rootScaffoldMessengerKey.currentState!.removeCurrentSnackBar();
}

class _ErrorSnackBar extends SnackBar {
  _ErrorSnackBar({required String title, String? detail})
      : super(
          content: ListTile(
            leading: const Icon(Icons.error),
            title: Text(title),
            subtitle: detail != null ? Text(detail) : null,
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: GetIt.instance<PreferencesController>()
              .theme
              .data
              .colorScheme
              .errorContainer,
          showCloseIcon: true,
          closeIconColor: GetIt.instance<PreferencesController>()
              .theme
              .data
              .colorScheme
              .onErrorContainer,
        );
}

class _InfoSnackBar extends SnackBar {
  _InfoSnackBar({required String title, String? detail})
      : super(
            content: ListTile(
              leading: const Icon(Icons.info),
              title: Text(title),
              subtitle: detail != null ? Text(detail) : null,
            ),
            duration: const Duration(seconds: 10),
            backgroundColor: GetIt.instance<PreferencesController>()
                .theme
                .data
                .colorScheme
                .surfaceContainerHigh,
            showCloseIcon: false);
}
