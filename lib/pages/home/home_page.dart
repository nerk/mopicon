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
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mopicon/components/busy_wrapper.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/services/mopidy_service.dart';

import '../settings/preferences_controller.dart';

class HomeView extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeView(this.navigationShell, {super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final mopidyService = GetIt.instance<MopidyService>();

  final preferences = GetIt.instance<PreferencesController>();

  int trackListCount = 0;
  bool showBusy = true;

  StreamSubscription? connectionSubscription;
  StreamSubscription? busySubscription;

  void initTrackListCount() async {
    int count = await mopidyService.getTracklistLength();
    if (mounted) {
      setState(() {
        trackListCount = count;
      });
    }
  }

  void updateTrackListCount() {
    if (mounted) {
      setState(() {
        trackListCount = mopidyService.tracklistChangedNotifier.value.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    GetIt.instance<MopidyService>().connect(preferences.url);
    showBusy = true;
    connectionSubscription = mopidyService.connectionState$.listen((MopidyConnectionState state) {
      setState(() {
        showBusy = state != MopidyConnectionState.online;
      });
    });
    busySubscription = mopidyService.busyState$.listen((bool busy) {
      setState(() {
        showBusy = busy ? true : !(!busy && mopidyService.connected);
      });
    });
    mopidyService.tracklistChangedNotifier.addListener(updateTrackListCount);
    initTrackListCount();
  }

  @override
  void dispose() {
    connectionSubscription?.cancel();
    busySubscription?.cancel();
    mopidyService.tracklistChangedNotifier.removeListener(updateTrackListCount);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BusyWrapper(
      Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            widget.navigationShell.goBranch(
              index,
              // A common pattern when using bottom navigation bars is to support
              // navigating to the initial location when tapping the item that is
              // already active. This example demonstrates how to support this behavior,
              // using the initialLocation parameter of goBranch.
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          selectedIndex: widget.navigationShell.currentIndex,
          destinations: <Widget>[
            NavigationDestination(icon: const Icon(Icons.search), label: S.of(context).homePageSearchLbl),
            NavigationDestination(icon: const Icon(Icons.radio), label: S.of(context).radioBrowserLbl),
            NavigationDestination(icon: const Icon(Icons.library_music), label: S.of(context).homePageBrowseLbl),
            NavigationDestination(
              icon: Badge(isLabelVisible: trackListCount > 0, label: Text('$trackListCount'), child: const Icon(Icons.queue_music)),
              label: S.of(context).homePageTracksLbl,
            ),
          ],
        ),
      ),
      showBusy,
    );
  }
}
