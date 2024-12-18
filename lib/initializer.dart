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

import 'package:get_it/get_it.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/services/file_service.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/services/cover_service.dart';
import 'package:mopicon/pages/browse/library_browser_controller.dart';
import 'package:mopicon/pages/playlist/playlist_view_controller.dart';
import 'package:mopicon/pages/tracklist/tracklist_view_controller.dart';
import 'package:mopicon/pages/search/search_view_controller.dart';
import 'package:mopicon/utils/logging_utils.dart';

/// Registers all services and loads preferences.
class Initializer {
  Initializer._();

  static Future<void> initialize() async {
    logger.i("initialize");
    // configure logger
    _registerServices();
    await _loadSettings();
    await _initializeFileService();
  }

  static void _registerServices() {
    GetIt getIt = GetIt.instance;
    logger.i("starting registering services");
    getIt.registerLazySingleton<PreferencesController>(
        () => PreferencesControllerImpl());
    getIt.registerLazySingleton<MopidyService>(() => MopidyServiceImpl());
    getIt.registerLazySingleton<CoverService>(() => CoverServiceImpl());
    getIt.registerLazySingleton<FileService>(() => FileServiceImpl());
    getIt.registerLazySingleton<LibraryBrowserController>(
        () => LibraryBrowserControllerImpl());
    getIt.registerLazySingleton<TracklistViewController>(
        () => TracklistViewControllerImpl());
    getIt.registerLazySingleton<PlaylistViewController>(
        () => PlaylistControllerImpl());
    getIt.registerLazySingleton<SearchViewController>(
        () => SearchViewControllerImpl());
    logger.i("finished registering services");
  }

  static Future<void> _loadSettings() async {
    logger.i("starting loading settings");
    await GetIt.instance<PreferencesController>().load();
    logger.i("finished loading settings");
  }

  static Future<void> _initializeFileService() async {
    try {
      logger.i("starting initializing file service");
      return GetIt.instance<FileService>().initialize();
    } finally {
      logger.i("finished initializing file service");
    }
  }
}
