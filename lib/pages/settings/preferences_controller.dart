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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mopidy_client/mopidy_client.dart' hide Image;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';
export 'app_themes.dart';
import 'app_locales.dart';
export 'app_locales.dart';

class Preferences {
  static const version = '1.0.0';
  static final Preferences _instance = Preferences._privateConstructor();

  final ValueNotifier<AppTheme> themeChanged =
      ValueNotifier(AppTheme.defaultAppTheme);

  factory Preferences() {
    return _instance;
  }

  Preferences._privateConstructor() {
    SharedPreferences.setPrefix('$version-');
  }

  bool valid = true;
  bool _dirty = false;

  final _defaultPort = 6680;
  final _defaultHost = 'localhost';

  late String? _host;
  late int? _port;
  AppTheme _theme = AppTheme.defaultAppTheme;
  AppLocale _appLocale = AppLocale.defaultLocale;

  bool _translateServerNames = false;
  bool _hideFileExtension = false;
  bool _showAllMediaCategories = false;

  /// Flag to indicate that search is supported. This is set to true
  /// after a connection has been established and the Mopidy server
  /// has the Mopidy-Local extension enabled.
  bool searchSupported = false;

  Future<void> load() async {
    var prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('mopidy_host') ?? _defaultHost;
    _port = prefs.getInt('mopidy_port') ?? _defaultPort;
    _theme = AppThemes().getByName(prefs.getString('theme'));
    themeChanged.value = _theme;
    _appLocale = AppLocales().getByLanguageCode(prefs.getString('locale'));
    _translateServerNames = prefs.getBool('translateServerNames') ?? false;
    _hideFileExtension = prefs.getBool('hideFileExtension') ?? false;
    _showAllMediaCategories = prefs.getBool('showAllMediaCategories') ?? false;
    _dirty = false;
  }

  Future<void> save() async {
    if (_dirty) {
      var prefs = await SharedPreferences.getInstance();
      _host != null
          ? prefs.setString('mopidy_host', _host!)
          : prefs.remove('mopidy_host');
      _port != null
          ? prefs.setInt('mopidy_port', _port!)
          : prefs.remove('mopidy_port');

      prefs.setString('theme', _theme.name);
      prefs.setString('locale', _appLocale.locale.languageCode);

      prefs.setBool('translateServerNames', _translateServerNames);
      prefs.setBool('hideFileExtension', _hideFileExtension);
      prefs.setBool('showAllMediaCategories', _showAllMediaCategories);
      _dirty = false;
    }
  }

  int? get port => _port;

  set port(int? p) {
    _port = p;
    _dirty = true;
  }

  String? get host => _host;

  set host(String? h) {
    _host = h;
    _dirty = true;
  }

  String get url {
    return "ws://$host:$port/mopidy/ws";
  }

  String computeNetworkUrl(MImage img) {
    return 'http://$host:$port${img.uri}';
  }

  bool get hasChanged => _dirty;

  AppTheme get theme {
    return _theme;
  }

  set theme(AppTheme t) {
    _theme = t;
    _dirty = true;
    themeChanged.value = t;
  }

  AppLocale get appLocale {
    return _appLocale;
  }

  set appLocale(AppLocale l) {
    _appLocale = l;
    _dirty = true;
  }

  bool get translateServerNames => _translateServerNames;

  set translateServerNames(bool f) {
    _translateServerNames = f;
    _dirty = true;
  }

  bool get hideFileExtension => _hideFileExtension;

  set hideFileExtension(bool f) {
    _hideFileExtension = f;
    _dirty = true;
  }

  bool get showAllMediaCategories => _showAllMediaCategories;

  set showAllMediaCategories(bool f) {
    _showAllMediaCategories = f;
    _dirty = true;
  }
}
