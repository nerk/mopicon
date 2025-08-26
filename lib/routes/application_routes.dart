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
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mopicon/pages/about/about_page.dart';
import 'package:mopicon/pages/browse/library_browser_controller.dart';
import 'package:mopicon/pages/browse/library_browser_page.dart';
import 'package:mopicon/pages/home/home_page.dart';
import 'package:mopicon/pages/playlist/playlist_page.dart';
import 'package:mopicon/pages/playlist/playlist_view_controller.dart';
import 'package:mopicon/pages/search/search_page.dart';
import 'package:mopicon/pages/search/search_view_controller.dart';
import 'package:mopicon/pages/radio_browser/radio_browser_page.dart';
import 'package:mopicon/pages/radio_browser/radio_browser_controller.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/pages/settings/preferences_page.dart';
import 'package:mopicon/pages/tracklist/tracklist_page.dart';
import 'package:mopicon/pages/tracklist/tracklist_view_controller.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/parameters.dart';

class ApplicationRoutes {
  static const String settingsPath = '/settings';
  static const String aboutPath = '/about';
  static const String browse = 'browse';
  static const String browsePath = '/browse';
  static const String down = 'down';
  static const String downPath = 'down/:parent';
  static const String playlist = 'playlist';
  static const String playlistPath = 'playlist/:parent';
  static const String tracks = 'tracks';
  static const String tracksPath = '/tracks';
  static const String search = 'search';
  static const String searchPath = '/search';
  static const String radio = 'radio';
  static const String radioPath = '/radio';

  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  late final GoRouter _router;

  final preferences = GetIt.instance<PreferencesController>();

  static final ApplicationRoutes _instance = ApplicationRoutes._privateConstructor();

  factory ApplicationRoutes() {
    return _instance;
  }

  ApplicationRoutes._privateConstructor() {
    _router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: preferences.host != null ? tracksPath : settingsPath,
      debugLogDiagnostics: true,
      routes: <RouteBase>[
        GoRoute(
          path: settingsPath,
          builder: (BuildContext context, GoRouterState state) {
            return const PreferencesPage();
          },
        ),
        GoRoute(
          path: aboutPath,
          builder: (BuildContext context, GoRouterState state) {
            return AboutPage();
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
            return HomeView(navigationShell);
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  onExit: (BuildContext c, _) {
                    GetIt.instance<SearchViewController>().notifyUnselect();
                    return true;
                  },
                  name: search,
                  path: searchPath,
                  builder: (BuildContext context, GoRouterState state) {
                    return const SearchPage();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  onExit: (BuildContext c, _) {
                    GetIt.instance<RadioBrowserController>().reset();
                    return true;
                  },
                  name: radio,
                  path: radioPath,
                  builder: (BuildContext context, GoRouterState state) {
                    return const RadioBrowserPage();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: browse,
                  path: browsePath,
                  builder: (BuildContext context, GoRouterState state) {
                    return const LibraryBrowserPage();
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      // unselect all potentially selected items
                      // and reset selection mode on exit
                      onExit: (BuildContext c, _) {
                        final controller = GetIt.instance<LibraryBrowserController>();
                        controller.notifyUnselect();
                        return true;
                      },
                      name: down,
                      path: downPath,
                      builder: (BuildContext context, GoRouterState state) {
                        return LibraryBrowserPage(
                          title: state.uri.queryParameters['title'],
                          parent: state.pathParameters['parent'],
                        );
                      },
                    ),
                    GoRoute(
                      // unselect all potentially selected items
                      // and reset selection mode on exit
                      onExit: (BuildContext c, _) {
                        final controller = GetIt.instance<PlaylistViewController>();
                        controller.notifyUnselect();
                        return true;
                      },
                      name: playlist,
                      path: playlistPath,
                      builder: (BuildContext context, GoRouterState state) {
                        return PlaylistPage(title: state.uri.queryParameters['title'], parent: state.pathParameters['parent']);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  redirect: (BuildContext context, GoRouterState state) {
                    // Use redirect to update TrackListPage's state
                    final controller = GetIt.instance<TracklistViewController>();
                    controller.notifyRefresh();
                    return null;
                  },
                  // unselect all potentially selected items
                  // and reset selection mode on exit
                  onExit: (BuildContext c, _) {
                    final controller = GetIt.instance<TracklistViewController>();
                    controller.notifyUnselect();
                    controller.splitEnabled.value = true;
                    return true;
                  },
                  name: tracks,
                  path: tracksPath,
                  builder: (BuildContext context, GoRouterState state) {
                    return const TrackListPage();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void gotoHome() {
    GoRouter.of(rootNavigatorKey.currentContext!).goNamed(tracks, queryParameters: <String, String>{'title': 'Tracks'});
  }

  void gotoSettings() {
    GoRouter.of(rootNavigatorKey.currentContext!).go(settingsPath);
  }

  void gotoAbout() {
    GoRouter.of(rootNavigatorKey.currentContext!).push(aboutPath);
  }

  void gotoSearch() {
    GoRouter.of(rootNavigatorKey.currentContext!).push(searchPath);
  }

  void gotoAlbum(Album album) {
    Ref item = Ref(album.uri!, album.name, Ref.typeAlbum);
    GoRouter.of(rootNavigatorKey.currentContext!).pushNamed(
      down,
      queryParameters: <String, String>{'title': item.name},
      pathParameters: <String, String>{'parent': Parameter.toBase64(item.toMap())},
    );
  }

  void goBack() {
    GoRouter.of(rootNavigatorKey.currentContext!).pop();
  }

  GoRouter get router => _router;
}

extension GoRouterExtension on GoRouter {
  Map<String, String> currentPathParameters() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    return matchList.pathParameters;
  }

  Ref? getParent() {
    String? parent = currentPathParameters()['parent'];
    if (parent == null) {
      return null;
    }
    return Ref.fromMap(Parameter.fromBase64(parent));
  }
}
