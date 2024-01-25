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
import 'package:mopicon/pages/tracklist/now_playing.dart';
import 'package:mopicon/components/action_buttons.dart';
import 'package:mopicon/components/volume_control.dart';
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/services/cover_service.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/components/reorderable_list_view.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/components/item_action_dialog.dart';
import 'tracklist_view_controller.dart';
import 'tracklist_appbar_menu.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({super.key});

  @override
  State<TrackListPage> createState() => _TrackListState();
}

class _TrackListState extends State<TrackListPage> {
  final controller = GetIt.instance<TracklistViewController>();

  // all tracks on the tracklist
  List<TlTrack> tracks = [];
  var images = <String, Widget?>{};

  // currently active track
  int? playingTlId;

  // if the currently active track is a stream
  bool isStream = false;

  // if the currently active track is a stream, the stream title
  String? streamTitle;

  // current position in track in milliseconds
  int timePosition = 0;

  // current playback state of current track
  String playbackState = PlaybackState.stopped;

  // selection mode (single/multiple) of track list view
  SelectionMode selectionMode = SelectionMode.off;

  // Whether window is split between list of tracks and NowPlaying section.
  // If false, NowPlaying covers whole window and is showing more details.
  bool splitEnabled = true;

  StreamSubscription? refreshSubscription;

  TlTrack? getTrackByTlid(int? tlid) {
    return tlid != null ? tracks.firstWhere((element) => tlid == element.tlid) : null;
  }

  int? getPositionByTlid(int? tlid) {
    return tlid != null ? tracks.indexWhere((element) => tlid == element.tlid) : null;
  }

  Widget getImage(TlTrack? track) {
    Widget w = CoverService.defaultTrack;
    if (track != null) {
      String uri = track.track.uri;
      w = images[uri] ??
          (uri.isStreamUri() ? ImageUtils.getIconForType(uri, Ref.typeTrack) : CoverService.defaultTrack);
    }
    return splitEnabled ? FittedBox(fit: BoxFit.cover, child: w) : ImageUtils.roundedCornersWithPadding(w, 200, 200);
  }

  // updates track list view from current track list and
  // updates cover thumbnails
  void updateTracks() async {
    List<TlTrack> trks = [];
    try {
      controller.mopidyService.setBusy(true);
      trks = await controller.loadTrackList();
      images = await trks.getImages();
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      trks = [];
      images = {};
    } finally {
      controller.mopidyService.setBusy(false);
      if (mounted) {
        setState(() {
          tracks = trks;
        });
      }
    }
  }

  // updates current track view, playback state und position within track.
  void updatePlayback() async {
    try {
      controller.mopidyService.setBusy(true);
      final tlTrack = await controller.mopidyService.getCurrentTlTrack();
      String? strTitle;
      if (tlTrack != null && tlTrack.track.uri.isStreamUri()) {
        strTitle = await controller.mopidyService.getStreamTitle();
      }

      final state = await controller.mopidyService.getPlaybackState();
      final position = await controller.mopidyService.getTimePosition();
      if (mounted) {
        setState(() {
          playingTlId =
              state != null && (state == PlaybackState.playing || state == PlaybackState.paused) ? tlTrack?.tlid : null;
          playbackState = state ?? playbackState;
          timePosition = position ?? 0;
          streamTitle = strTitle;
          isStream = tlTrack != null ? tlTrack.track.uri.isStreamUri() : false;
        });
      }
    } catch (e) {
      logger.e(e);
    } finally {
      controller.mopidyService.setBusy(false);
    }
  }

  // updates current track view, playback state und position within track.
  void updateTrackPlayback() async {
    try {
      TrackPlaybackInfo? info = controller.mopidyService.trackPlaybackNotifier.value;
      if (info != null) {
        var state = PlaybackState.stopped;
        switch (info.state) {
          case TrackState.paused:
            state = PlaybackState.paused;
            break;
          case TrackState.started:
          case TrackState.resumed:
            state = PlaybackState.playing;
            break;
          case TrackState.ended:
            state = PlaybackState.stopped;
            break;
        }

        setState(() {
          playbackState = state;
          playingTlId = (state == PlaybackState.playing || state == PlaybackState.paused) ? info.tlTrack.tlid : null;
          timePosition = info.timePosition;
          streamTitle = info.tlTrack.track.name;
          isStream = info.tlTrack.track.uri.isStreamUri();
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void updateSelection() {
    setState(() {
      selectionMode = controller.selectionMode;
    });
  }

  void updateStreamTitle() {
    setState(() {
      streamTitle = controller.mopidyService.streamTitleChangedNotifier.value;
    });
  }

  void updateSplitMode() {
    setState(() {
      splitEnabled = controller.splitEnabled.value;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshSubscription = controller.refresh$.listen((_) {
      updateTracks();
      updatePlayback();
    });

    controller.mopidyService.tracklistChangedNotifier.addListener(updateTracks);
    controller.mopidyService.trackPlaybackNotifier.addListener(updateTrackPlayback);
    controller.mopidyService.playbackStateNotifier.addListener(updatePlayback);
    controller.mopidyService.streamTitleChangedNotifier.addListener(updateStreamTitle);
    controller.selectionModeChanged.addListener(updateSelection);
    controller.selectionChanged.addListener(updateSelection);
    controller.splitEnabled.addListener(updateSplitMode);
    updateTracks();
    updateStreamTitle();
    updateSelection();
    updatePlayback();
    updateSplitMode();
  }

  @override
  void dispose() {
    controller.mopidyService.tracklistChangedNotifier.removeListener(updateTracks);
    controller.mopidyService.trackPlaybackNotifier.removeListener(updateTrackPlayback);
    controller.mopidyService.playbackStateNotifier.removeListener(updatePlayback);
    controller.mopidyService.streamTitleChangedNotifier.removeListener(updateStreamTitle);
    controller.selectionModeChanged.removeListener(updateSelection);
    controller.selectionChanged.removeListener(updateSelection);
    controller.splitEnabled.removeListener(updateSplitMode);
    refreshSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void itemMovedCb(int start, int current) async {
      try {
        if (start < current) {
          await controller.mopidyService.move(start, current - 1);
        } else {
          await controller.mopidyService.move(start, current);
        }
      } catch (e) {
        logger.e(e);
      }
    }

    void onTappedCb(TlTrack track, int index) async {
      var r = await showActionDialog([ItemActionOption.play, ItemActionOption.addToPlaylist]);
      switch (r) {
        case ItemActionOption.play:
          controller.mopidyService.play(track.asRef);
          break;
        case ItemActionOption.addToPlaylist:
          if (context.mounted) {
            await controller.addItemsToPlaylist<Ref>(context, [track.asRef]);
          }
          break;
        default:
      }
    }

    var listView = ReorderableTrackListView<TlTrack>(context, tracks, images, controller.selectionChanged,
            controller.selectionModeChanged, itemMovedCb, onTappedCb,
            markedItemIndex: getPositionByTlid(playingTlId))
        .buildListView();

    // section with contents of currently playing track
    var currentlyPlayingView = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) async {
          try {
            if (splitEnabled && details.velocity.pixelsPerSecond.dy > -100 ||
                !splitEnabled && details.velocity.pixelsPerSecond.dy < 100) {
              return;
            }
            // store the position in current track
            timePosition = (await controller.mopidyService.getTimePosition()) ?? timePosition;
            controller.splitEnabled.value = !splitEnabled;
          } catch (e) {
            logger.e(e);
          }
        },
        child: Column(children: [
          // top divider with handle button
          Stack(alignment: Alignment.center, children: [
            const Center(child: Divider(height: 34, thickness: 3.0)),
            Center(
                child: IconButton.filled(
              constraints: BoxConstraints.tight(const Size(34, 34)),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
              icon: splitEnabled ? const Icon(Icons.arrow_circle_up) : const Icon(Icons.arrow_circle_down),
              onPressed: () async {
                try {
                  // store the position in current track
                  timePosition = (await controller.mopidyService.getTimePosition()) ?? timePosition;
                  controller.splitEnabled.value = !splitEnabled;
                } catch (e) {
                  logger.e(e);
                }
              },
            )),
          ]),
          // the actual contents
          NowPlaying(splitEnabled, getTrackByTlid(playingTlId), getImage(getTrackByTlid(playingTlId)), playbackState,
              timePosition, streamTitle, isStream),
          // bottom divider
          const Center(child: Divider(thickness: 1.0)),
        ]));

    // full size mode
    var currentlyPlayingFull = Expanded(flex: 1, child: currentlyPlayingView);
    // split view  mode
    var currentlyPlayingSplit = currentlyPlayingView;

    Widget currentlyPlayingPanel = const SizedBox();
    if (playingTlId != null) {
      if (splitEnabled) {
        if (playbackState != PlaybackState.stopped) {
          currentlyPlayingPanel = currentlyPlayingSplit;
        }
      } else {
        if (playbackState != PlaybackState.stopped) {
          currentlyPlayingPanel = currentlyPlayingFull;
        } else {
          controller.splitEnabled.value = true;
        }
      }
    } else {
      controller.splitEnabled.value = true;
    }

    var children = splitEnabled ? [Expanded(child: listView), currentlyPlayingPanel] : [currentlyPlayingPanel];

    return Scaffold(
      appBar: AppBar(
          title: Text(S.of(context).trackListPageTitle),
          centerTitle: true,
          leading:
              ActionButton<SelectedItemPositions>(Icons.arrow_back, valueListenable: controller.selectionChanged, () {
            controller.notifyUnselect();
          }),
          actions: [
            ActionButton<SelectedItemPositions>(
                Icons.delete, valueListenable: controller.selectionChanged, controller.deleteSelectedTracks),
            ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
              var selectedItems = await controller.getSelectedItems();
              if (context.mounted) {
                await controller.addItemsToPlaylist<Ref>(context, selectedItems);
              }
              controller.notifyUnselect();
            }, valueListenable: controller.selectionChanged),
            VolumeControl(),
            TracklistAppBarMenu(controller)
          ]),
      body: MaterialPageFrame(child: Column(mainAxisSize: MainAxisSize.max, children: children)),
    );
  }
}
