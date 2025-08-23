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
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/services/file_service.dart';

/// Displays information about this program, with links to sourcecode
/// and documentation.
class AboutPage extends StatelessWidget {
  final _preferences = GetIt.instance<PreferencesController>();
  final _fileService = GetIt.instance<FileService>();

  AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    String about = _fileService.about(_preferences.appLocale.locale);
    about = about.replaceAll(RegExp(r'\{\{\s*version\s*\}\}'), _preferences.version);
    about = about.replaceAll(RegExp(r'\{\{\s*build\s*\}\}'), _preferences.buildNumber);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true, centerTitle: true, title: Text(S.of(context).aboutPageTitle)),
      body: Material(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Center(child: HtmlWidget(about, factoryBuilder: () => MyWidgetFactory())),
        ),
      ),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
