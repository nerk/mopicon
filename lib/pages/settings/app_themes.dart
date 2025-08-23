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

class AppTheme {
  String name;
  late ThemeData data;
  late bool dark;

  AppTheme(Color color, this.name, this.dark) {
    data = _createTheme(color, dark);
  }

  AppTheme.light(this.name) {
    dark = false;
    data = ThemeData.light(useMaterial3: true);
  }

  AppTheme.dark(this.name) {
    dark = true;
    data = ThemeData.dark(useMaterial3: true);
  }

  @override
  bool operator ==(other) => other is AppTheme && name == other.name && dark == other.dark;

  @override
  int get hashCode => Object.hash(name, dark);

  ThemeData _createTheme(Color color, bool dark) {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: color, brightness: dark ? Brightness.dark : Brightness.light),
      useMaterial3: true,
    );
  }
}

class AppThemes {
  static final AppThemes _instance = AppThemes._privateConstructor();

  static final _lightThemes = [
    AppTheme.light('default'),
    AppTheme(Colors.orange, 'orange', false),
    AppTheme(Colors.red, 'red', false),
    AppTheme(Colors.purple, 'purple', false),
    AppTheme(Colors.teal, 'teal', false),
    AppTheme(Colors.blue, 'blue', false),
    AppTheme(Colors.cyan, 'cyan', false),
    AppTheme(Colors.amber, 'amber', false),
  ];

  static final _darkThemes = [
    AppTheme.dark('default'),
    AppTheme(Colors.orange, 'orange', true),
    AppTheme(Colors.red, 'red', true),
    AppTheme(Colors.purple, 'purple', true),
    AppTheme(Colors.teal, 'teal', true),
    AppTheme(Colors.blue, 'blue', true),
    AppTheme(Colors.cyan, 'cyan', true),
    AppTheme(Colors.amber, 'amber', true),
  ];

  factory AppThemes() {
    return _instance;
  }

  AppThemes._privateConstructor();

  static AppTheme get(String? name, bool? dark) {
    if (name == null) {
      return _darkThemes[0];
    }

    if (dark == null || dark) {
      return _darkThemes.firstWhere((e) => e.name == name, orElse: () => _darkThemes[0]);
    } else {
      return _lightThemes.firstWhere((e) => e.name == name, orElse: () => _lightThemes[0]);
    }
  }

  static AppTheme get defaultTheme => _darkThemes[0];

  static List<AppTheme> get lightThemes => _lightThemes;

  static List<AppTheme> get darkThemes => _darkThemes;
}
