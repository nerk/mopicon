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
import 'package:intl/intl.dart';
import 'package:universal_io/io.dart';
import 'package:country/country.dart';
import 'package:country_flags/country_flags.dart';

class CountryInfo {
  String iso31661;
  String displayName;
  Widget flag;

  CountryInfo(this.iso31661, this.displayName, this.flag);

  @override
  String toString() {
    return "$iso31661,$displayName";
  }
}

class AppLocale {
  static final labels = <String, Map<String, String>>{
    'en': {'en': 'English', 'de': 'German'},
    'de': {'en': 'Englisch', 'de': 'Deutsch'},
  };

  static AppLocale defaultLocale = AppLocale.system();

  late Locale locale;

  late Map<String, CountryInfo> countries;

  String getLabel(String currentLanguageCode) {
    var label = labels.containsKey(currentLanguageCode)
        ? labels[currentLanguageCode]![locale.languageCode]
        : labels[defaultLocale.locale.languageCode]![locale.languageCode];

    if (label != null) {
      return label;
    }

    return label ?? locale.languageCode;
  }

  AppLocale.english() {
    locale = const Locale('en', 'GB');
    countries = _countryInfoListByLocale(locale);
  }

  AppLocale.german() {
    locale = const Locale('de', 'DE');
    countries = _countryInfoListByLocale(locale);
  }

  AppLocale.system() {
    var lang = _language(Intl.systemLocale);
    var country = _country(Intl.systemLocale);
    locale = labels[lang] != null ? Locale(lang, country) : const Locale('en', 'GB');
    countries = _countryInfoListByLocale(locale);
  }

  static String _language(String languageCode) {
    return languageCode.split('-')[0].split('_')[0];
  }

  static String _country(String languageCode) {
    return languageCode.split('-')[0].split('_')[1];
  }

  static Map<String, CountryInfo> _countryInfoListByLocale(Locale lc) {
    var map = <String, CountryInfo>{};
    var cc = lc.languageCode;
    for (var c in Countries.values) {
      String s = c.isoShortNameByLocale[cc.toLowerCase()] ?? '';
      var flag = CountryFlag.fromCountryCode(c.alpha2, width: 40, height: 20);
      map[c.alpha2] = CountryInfo(c.alpha2, s, flag);
    }
    return map;
  }

  @override
  bool operator ==(other) => other is AppLocale && locale.languageCode == other.locale.languageCode;

  @override
  int get hashCode => locale.languageCode.hashCode;
}

class AppLocales {
  static final AppLocales _instance = AppLocales._privateConstructor();

  final _locales = [AppLocale.german(), AppLocale.english()];

  factory AppLocales() {
    return _instance;
  }

  AppLocales._privateConstructor();

  AppLocale getByLanguageCode(String? languageCode) {
    languageCode = languageCode ?? Platform.localeName;

    return _locales.firstWhere(
      (e) => e.locale.languageCode == languageCode,
      orElse: () {
        return _resolveFallback(languageCode!);
      },
    );
  }

  List<AppLocale> get locales => _locales;

  AppLocale _resolveFallback(String languageCode) {
    final lang = languageCode.split('-')[0].split('_')[0];
    return _locales.firstWhere((e) => e.locale.languageCode == lang, orElse: () => AppLocale.defaultLocale);
  }
}
