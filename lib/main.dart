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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/common/globals.dart';
import 'package:mopicon/initializer.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';

import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Initializer.initialize();
  return runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  AppWidget({super.key});

  final preferences = GetIt.instance<PreferencesController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: preferences.preferencesChanged$,
      builder: (_, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          key: Globals.rootNavigatorKey,
          scaffoldMessengerKey: Globals.rootScaffoldMessengerKey,
          title: 'Mopicon',
          theme: preferences.theme.data,
          routerConfig: Globals.applicationRoutes.router,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: preferences.appLocale.locale,
        );
      },
    );
  }
}
