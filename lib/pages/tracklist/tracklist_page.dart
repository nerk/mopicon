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
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/pages/tracklist/now_playing.dart';
import 'package:mopicon/components/action_buttons.dart';
import 'package:mopicon/components/volume_control.dart';
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/utils/globals.dart';
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/services/cover_service.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';
import 'package:mopicon/components/reorderable_list_view.dart';
import 'package:mopicon/components/selected_item_positions.dart';
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
  final mopidyService = GetIt.instance<MopidyService>();

  // all tracks on the tracklist
  List<TlTrack> tracks = [];
  var images = <String, Widget>{};

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

  TlTrack? getTrackByTlid(int? tlid) {
    return tracks.firstWhereOrNull((element) => tlid == element.tlid);
  }

  int? getPositionByTlid(int? tlid) {
    return tracks.indexWhere((element) => tlid == element.tlid);
  }

  Widget getImage(TlTrack? track) {
    return splitEnabled
        ? (images[track?.track.uri] ?? CoverService.defaultImage)
        : ImageUtils.roundedCornersWithPadding(images[track?.track.uri] ?? CoverService.defaultImage, 200, 200);
  }

  // updates track list view from current track list and
  // updates cover thumbnails
  void updateTracks() async {
    try {
      var trks = await controller.loadTrackList();
      // load images into local map

      for (TlTrack tlt in trks) {
        if (images[tlt.track.uri] == null) {
          var image = await tlt.track.getImage();
          images.putIfAbsent(tlt.track.uri, () => image);
        }
      }

      setState(() {
        tracks = trks;
      });
    } catch (e, s) {
      Globals.logger.e(e, stackTrace: s);
    }
  }

  // updates current track view, playback state und position within track.
  void updatePlayback() async {
    try {
      final tlTrack = await mopidyService.getCurrentTlTrack();
      String? strTitle;
      if (tlTrack != null && tlTrack.track.uri.isStreamUri()) {
        strTitle = await mopidyService.getStreamTitle();
      }

      final state = await mopidyService.getPlaybackState();
      final position = await mopidyService.getTimePosition();
      setState(() {
        playingTlId =
            state != null && (state == PlaybackState.playing || state == PlaybackState.paused) ? tlTrack?.tlid : null;
        playbackState = state ?? playbackState;
        timePosition = position ?? 0;
        streamTitle = strTitle;
        isStream = tlTrack != null ? tlTrack.track.uri.isStreamUri() : false;
      });
    } catch (e) {
      Globals.logger.e(e);
    }
  }

  // updates current track view, playback state und position within track.
  void updateTrackPlayback() async {
    try {
      TrackPlaybackInfo? info = mopidyService.trackPlaybackNotifier.value;
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
      Globals.logger.e(e);
    }
  }

  void updateSelection() {
    setState(() {
      selectionMode = controller.selectionModeChanged.value;
    });
  }

  void updateStreamTitle() {
    setState(() {
      streamTitle = mopidyService.streamTitleChangedNotifier.value;
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
    mopidyService.trackListChangedNotifier.addListener(updateTracks);
    mopidyService.trackPlaybackNotifier.addListener(updateTrackPlayback);
    mopidyService.playbackStateNotifier.addListener(updatePlayback);
    mopidyService.streamTitleChangedNotifier.addListener(updateStreamTitle);
    controller.selectionModeChanged.addListener(updateSelection);
    controller.selectionChanged.addListener(updateSelection);
    controller.splitEnabled.addListener(updateSplitMode);
    updateTracks();
    updateStreamTitle();
    updateSelection();
    updatePlayback();
    updateSplitMode();

    SystemChannels.lifecycle.setMessageHandler((msg) {
      // When the app was resumed, update
      // tracklist state.
      if (msg == 'AppLifecycleState.resumed') {
        updateTracks();
        updateStreamTitle();
        updatePlayback();
      }
      return Future.value(null);
    });
  }

  @override
  void dispose() {
    mopidyService.trackListChangedNotifier.removeListener(updateTracks);
    mopidyService.trackPlaybackNotifier.removeListener(updateTrackPlayback);
    mopidyService.playbackStateNotifier.removeListener(updatePlayback);
    mopidyService.streamTitleChangedNotifier.removeListener(updateStreamTitle);
    controller.selectionModeChanged.removeListener(updateSelection);
    controller.selectionChanged.removeListener(updateSelection);
    controller.splitEnabled.removeListener(updateSplitMode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void itemMovedCb(int start, int current) async {
      try {
        if (start < current) {
          await mopidyService.move(start, current - 1);
        } else {
          await mopidyService.move(start, current);
        }
      } catch (e) {
        Globals.logger.e(e);
      }
    }

    void onTappedCb(TlTrack track, int index) async {
      var r = await showActionDialog([ItemActionOption.play, ItemActionOption.addToPlaylist]);
      switch (r) {
        case ItemActionOption.play:
          mopidyService.play(track.asRef);
          break;
        case ItemActionOption.addToPlaylist:
          await controller.addItemsToPlaylist<Ref>([track.asRef]);
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
            timePosition = (await mopidyService.getTimePosition()) ?? timePosition;
            controller.splitEnabled.value = !splitEnabled;
          } catch (e) {
            Globals.logger.e(e);
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
                  timePosition = (await mopidyService.getTimePosition()) ?? timePosition;
                  controller.splitEnabled.value = !splitEnabled;
                } catch (e) {
                  Globals.logger.e(e);
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
              controller.unselect();
            }),
            actions: [
              ActionButton<SelectedItemPositions>(
                  Icons.delete, valueListenable: controller.selectionChanged, controller.deleteSelectedTracks),
              ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
                var selectedItems = await controller.getSelectedItems();
                await controller.addItemsToPlaylist<Ref>(selectedItems);
                controller.unselect();
              }, valueListenable: controller.selectionChanged),
              VolumeControl(),
              TracklistAppBarMenu(controller)
            ]),
        body: MaterialPageFrame(child: Column(mainAxisSize: MainAxisSize.max, children: children)));
  }
}
