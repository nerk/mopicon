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
import 'package:mopidy_client/mopidy_client.dart' hide Image;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'app_themes.dart';
export 'app_themes.dart';
import 'app_locales.dart';
export 'app_locales.dart';

abstract class PreferencesController {
  /// Notification about current connection state.
  Stream<void> get preferencesChanged$;

  String get version;

  Future<void> load();

  Future<void> save();

  int? get port;

  set port(int? p);

  String? get host;

  set host(String? h);

  String get url;

  String computeNetworkUrl(MImage img);

  bool get hasChanged;

  AppTheme get theme;

  set theme(AppTheme t);

  AppLocale get appLocale;

  set appLocale(AppLocale l);

  bool get translateServerNames;

  set translateServerNames(bool f);

  bool get hideFileExtension;

  set hideFileExtension(bool f);

  bool get showAllMediaCategories;

  set showAllMediaCategories(bool f);

  bool get searchSupported;

  set searchSupported(bool v);
}

class PreferencesControllerImpl extends PreferencesController {
  static const _version = '1.0.0';

  final _preferencesChanged$ = PublishSubject<void>();

  @override
  Stream<void> get preferencesChanged$ => _preferencesChanged$.stream;

  PreferencesControllerImpl() {
    SharedPreferences.setPrefix('$_version-');
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

  @override
  String get version => _version;

  /// Flag to indicate that search is supported. This is set to true
  /// after a connection has been established and the Mopidy server
  /// has the Mopidy-Local extension enabled.
  bool _searchSupported = false;

  bool get searchSupported => _searchSupported;

  set searchSupported(bool v) => _searchSupported = v;

  @override
  Future<void> load() async {
    var prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('mopidy_host') ?? _defaultHost;
    _port = prefs.getInt('mopidy_port') ?? _defaultPort;
    _theme = AppThemes().getByName(prefs.getString('theme'));
    _appLocale = AppLocales().getByLanguageCode(prefs.getString('locale'));
    _translateServerNames = prefs.getBool('translateServerNames') ?? false;
    _hideFileExtension = prefs.getBool('hideFileExtension') ?? false;
    _showAllMediaCategories = prefs.getBool('showAllMediaCategories') ?? false;
    _dirty = false;
  }

  @override
  Future<void> save() async {
    if (_dirty) {
      var prefs = await SharedPreferences.getInstance();
      _host != null ? prefs.setString('mopidy_host', _host!) : prefs.remove('mopidy_host');
      _port != null ? prefs.setInt('mopidy_port', _port!) : prefs.remove('mopidy_port');

      prefs.setString('theme', _theme.name);
      prefs.setString('locale', _appLocale.locale.languageCode);

      prefs.setBool('translateServerNames', _translateServerNames);
      prefs.setBool('hideFileExtension', _hideFileExtension);
      prefs.setBool('showAllMediaCategories', _showAllMediaCategories);
      _dirty = false;
      _preferencesChanged$.add(null);
    }
  }

  @override
  int? get port => _port;

  @override
  set port(int? p) {
    _dirty = _dirty || p != _port;
    _port = p;
  }

  @override
  String? get host => _host;

  @override
  set host(String? h) {
    _dirty = _dirty || h != _host;
    _host = h;
  }

  @override
  String get url {
    return "ws://$host:$port/mopidy/ws";
  }

  @override
  String computeNetworkUrl(MImage img) {
    var uri = Uri.parse(img.uri);
    return uri.hasScheme ? img.uri : 'http://$host:$port${img.uri}';
  }

  @override
  bool get hasChanged => _dirty;

  @override
  AppTheme get theme {
    return _theme;
  }

  @override
  set theme(AppTheme t) {
    _dirty = _dirty || t != _theme;
    _theme = t;
  }

  @override
  AppLocale get appLocale {
    return _appLocale;
  }

  @override
  set appLocale(AppLocale l) {
    _dirty = _dirty || l != _appLocale;
    _appLocale = l;
  }

  @override
  bool get translateServerNames => _translateServerNames;

  @override
  set translateServerNames(bool f) {
    _dirty = _dirty || f != _translateServerNames;
    _translateServerNames = f;
  }

  @override
  bool get hideFileExtension => _hideFileExtension;

  @override
  set hideFileExtension(bool f) {
    _dirty = _dirty || f != _hideFileExtension;
    _hideFileExtension = f;
  }

  @override
  bool get showAllMediaCategories => _showAllMediaCategories;

  @override
  set showAllMediaCategories(bool f) {
    _dirty = _dirty || f != _showAllMediaCategories;
    _showAllMediaCategories = f;
  }
}
