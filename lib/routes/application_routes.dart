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
import 'package:mopicon/pages/playlist/playlist_view_controller.dart';
import 'package:mopicon/pages/tracklist/tracklist_page.dart';
import 'package:go_router/go_router.dart';
import 'package:mopicon/pages/home/home_page.dart';
import 'package:mopicon/pages/browse/library_browser_page.dart';
import 'package:mopicon/pages/browse/library_browser_controller.dart';
import 'package:mopicon/pages/playlist/playlist_page.dart';
import 'package:mopicon/pages/settings/preferences_page.dart';
import 'package:mopicon/pages/about/about_page.dart';
import 'package:mopicon/pages/splash_screen/splash_screen.dart';
import 'package:mopicon/pages/connecting_screen/connecting_screen.dart';
import 'package:mopicon/pages/tracklist/tracklist_view_controller.dart';
import 'package:mopicon/pages/search/search_page.dart';
import 'package:mopicon/pages/search/search_view_controller.dart';
import 'package:mopicon/utils/parameters.dart';
import 'package:mopicon/services/mopidy_service.dart';

class ApplicationRoutes {
  static const String home = 'home';
  static const String splashPath = '/splash';
  static const String connecting = 'connecting';
  static const String connectingPath = '/connecting';
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

  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  late final GoRouter _router;

  static final ApplicationRoutes _instance =
      ApplicationRoutes._privateConstructor();

  factory ApplicationRoutes() {
    return _instance;
  }

  ApplicationRoutes._privateConstructor() {
    _router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: splashPath,
        debugLogDiagnostics: true,
        routes: <RouteBase>[
          GoRoute(
            path: splashPath,
            builder: (BuildContext context, GoRouterState state) {
              return const SplashScreen();
            },
          ),
          GoRoute(
            name: connecting,
            path: connectingPath,
            builder: (BuildContext context, GoRouterState state) {
              return ConnectingScreen(
                maxRetries:
                    int.parse(state.uri.queryParameters['maxRetries'] ?? '0'),
              );
            },
          ),
          GoRoute(
            path: settingsPath,
            builder: (BuildContext context, GoRouterState state) {
              return const PreferencesPage();
            },
          ),
          GoRoute(
            path: aboutPath,
            builder: (BuildContext context, GoRouterState state) {
              return const AboutPage();
            },
          ),
          StatefulShellRoute.indexedStack(
              builder: (BuildContext context, GoRouterState state,
                  StatefulNavigationShell navigationShell) {
                return HomeView(navigationShell);
              },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                    onExit: (BuildContext c) {
                      GetIt.instance<SearchViewController>().unselect();
                      return true;
                    },
                    name: search,
                    path: searchPath,
                    builder: (BuildContext context, GoRouterState state) {
                      return const SearchPage();
                    },
                  ),
                ]),
                StatefulShellBranch(routes: <RouteBase>[
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
                            onExit: (BuildContext c) {
                              final controller =
                                  GetIt.instance<LibraryBrowserController>();
                              controller.unselect();
                              return true;
                            },
                            name: down,
                            path: downPath,
                            builder:
                                (BuildContext context, GoRouterState state) {
                              return LibraryBrowserPage(
                                title: state.uri.queryParameters['title'],
                                parent: state.pathParameters['parent'],
                              );
                            }),
                        GoRoute(
                            // unselect all potentially selected items
                            // and reset selection mode on exit
                            onExit: (BuildContext c) {
                              final controller =
                                  GetIt.instance<PlaylistViewController>();
                              controller.unselect();
                              return true;
                            },
                            name: playlist,
                            path: playlistPath,
                            builder:
                                (BuildContext context, GoRouterState state) {
                              return PlaylistPage(
                                title: state.uri.queryParameters['title'],
                                parent: state.pathParameters['parent'],
                              );
                            }),
                      ])
                ]),
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                    // unselect all potentially selected items
                    // and reset selection mode on exit
                    onExit: (BuildContext c) {
                      final controller =
                          GetIt.instance<TracklistViewController>();
                      controller.unselect();
                      controller.splitEnabled.value = true;
                      return true;
                    },
                    name: tracks,
                    path: tracksPath,
                    builder: (BuildContext context, GoRouterState state) {
                      return const TrackListPage();
                    },
                  ),
                ]),
              ])
        ]);
  }

  void gotoHome() {
    GoRouter.of(rootNavigatorKey.currentContext!)
        .goNamed(tracks, queryParameters: <String, String>{'title': 'Tracks'});
  }

  void gotoConnecting(int maxRetries) {
    GoRouter.of(rootNavigatorKey.currentContext!).goNamed(connecting,
        queryParameters: <String, String>{'maxRetries': maxRetries.toString()});
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

  GoRouter get router => _router;
}

extension GoRouterExtension on GoRouter {
  Map<String, String> currentPathParameters() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
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
