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

class AppTheme {
  static AppTheme defaultAppTheme = AppTheme.light('default_light');

  late ThemeData data;
  String name;

  AppTheme(Color color, this.name, bool dark) {
    data = _createTheme(color, dark);
  }

  AppTheme.light(this.name) {
    data = ThemeData.light(useMaterial3: true);
  }
  AppTheme.dark(this.name) {
    data = ThemeData.dark(useMaterial3: true);
  }

  @override
  bool operator ==(other) => other is AppTheme && name == other.name;

  @override
  int get hashCode => name.hashCode;

  ThemeData _createTheme(Color color, bool dark) {
    return ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: color,
            brightness: dark ? Brightness.dark : Brightness.light),
        useMaterial3: true);
  }
}

class AppThemes {
  static final AppThemes _instance = AppThemes._privateConstructor();

  final _themes = List<AppTheme>.empty(growable: true);

  factory AppThemes() {
    return _instance;
  }

  AppThemes._privateConstructor() {
    _themes.add(AppTheme.light('default_light'));
    _themes.add(AppTheme.dark('default_dark'));
    _themes.add(AppTheme(Colors.red, 'red_light', false));
    _themes.add(AppTheme(Colors.red, 'red_dark', true));
    _themes.add(AppTheme(Colors.teal, 'teal_light', false));
    _themes.add(AppTheme(Colors.teal, 'teal_dark', true));
    _themes.add(AppTheme(Colors.orange, 'orange_light', false));
    _themes.add(AppTheme(Colors.orange, 'orange_dark', true));
    _themes.add(AppTheme(Colors.purple, 'purple_light', false));
    _themes.add(AppTheme(Colors.purple, 'purple_dark', true));
  }

  AppTheme getByName(String? name) {
    if (name == null) {
      return AppTheme.defaultAppTheme;
    }
    return _themes.firstWhere((e) => e.name == name,
        orElse: () => AppTheme.defaultAppTheme);
  }

  List<AppTheme> get themes => _themes;
}
