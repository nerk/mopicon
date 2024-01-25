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
import 'package:mopicon/pages/tracklist/playing_progress.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/utils/image_utils.dart';
import 'package:mopicon/components/rd_list_tile.dart';
import 'package:mopicon/generated/l10n.dart';

class NowPlaying extends StatelessWidget {
  final bool splitPage;
  final Widget cover;
  final TlTrack? currentTlTrack;
  final String playbackState;
  final int timePosition;
  final String? streamTitle;

  final bool isStream;

  const NowPlaying(this.splitPage, this.currentTlTrack, this.cover, this.playbackState, this.timePosition,
      this.streamTitle, this.isStream,
      {super.key});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String artistName = '';
    String albumName = '';
    int length = 0;
    String date = '';
    int discNo = 0;
    int trackNo = 0;
    int bitrate = 0;

    if (currentTlTrack != null) {
      length = currentTlTrack!.track.length ?? 0;
      date = currentTlTrack!.track.date ?? '';
      trackNo = currentTlTrack!.track.trackNo ?? 0;
      bitrate = currentTlTrack!.track.bitrate ?? 0;
      // If this is an infinite stream, i.p. length is 0
      if (isStream && length == 0) {
        artistName = currentTlTrack!.track.name; // Station name
        title = streamTitle != null ? streamTitle! : artistName;
        if (title == artistName) {
          artistName = '';
        }
        albumName = currentTlTrack!.track.uri;
      } else {
        title = currentTlTrack!.track.name;
        artistName = currentTlTrack!.track.artists.map((e) => e.name).nonNulls.join(', ');
        albumName = currentTlTrack!.track.album?.name ?? '';
        discNo = currentTlTrack!.track.discNo ?? 0;
      }
    }

    if (splitPage) {
      return _small(title, artistName, albumName, length, bitrate);
    } else {
      return _big(context, title, artistName, albumName, length, date, discNo, trackNo, bitrate);
    }
  }

  Widget _big(BuildContext context, String title, String artistName, String albumName, int length, String date,
      int discNo, int trackNo, int bitrate) {
    return Expanded(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(children: [
              Container(padding: const EdgeInsets.all(8), child: Center(child: cover)),
              Center(child: Text(title, style: const TextStyle(fontSize: 20.0))),
              Center(child: Text(artistName, style: const TextStyle(fontSize: 18.0))),
              Center(child: Text(albumName, style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic)))
            ]),
            Column(children: [
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                if (!isStream) Text(S.of(context).nowPlayingDiscLbl(discNo)),
                if (trackNo != 0) Text(S.of(context).nowPlayingTrackNoLbl(trackNo)),
                if (date.isNotEmpty) Text(S.of(context).nowPlayingDateLbl(date)),
              ]),
              PlayingProgressIndicator(
                  Duration(milliseconds: length), playbackState, timePosition, bitrate, _getButtons, isStream)
            ]),
          ],
        ));
  }

  Widget _small(String title, String artistName, String albumName, int length, int bitrate) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RdListTile(
          0,
          //isThreeLine: true,
          leading: ImageUtils.resize(cover, 40, 40),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          subtitle: Text(artistName, style: const TextStyle(fontSize: 12)),
          //trailing: Row(mainAxisSize: MainAxisSize.min, children: _getButtons()),
        ),
        PlayingProgressIndicator(
            Duration(milliseconds: length), playbackState, timePosition, bitrate, _getButtons, isStream),
      ],
    );
  }

  List<Widget> _getButtons() {
    if (playbackState == PlaybackState.playing) {
      return [_PreviousButton(), _PauseButton(), _StopButton(), _NextButton()];
    } else if (playbackState == PlaybackState.paused) {
      return [_PreviousButton(), _PlayButton(null), _StopButton(), _NextButton()];
    } else if (playbackState == PlaybackState.stopped) {
      return [_PlayButton(currentTlTrack?.tlid)];
    } else {
      return [];
    }
  }
}

class _PlayButton extends StatelessWidget {
  final _mopidyService = GetIt.instance<MopidyService>();

  final int? tlid;

  _PlayButton(this.tlid);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          try {
            if (tlid != null) {
              _mopidyService.playback(PlaybackAction.play, tlid);
            } else {
              _mopidyService.playback(PlaybackAction.resume, null);
            }
          } catch (e) {
            logger.e(e);
          }
        },
        icon: const Icon(Icons.play_arrow));
  }
}

class _PauseButton extends StatelessWidget {
  final _mopidyService = GetIt.instance<MopidyService>();

  _PauseButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          try {
            _mopidyService.playback(PlaybackAction.pause, null);
          } catch (e) {
            logger.e(e);
          }
        },
        icon: const Icon(Icons.pause));
  }
}

class _StopButton extends StatelessWidget {
  final _mopidyService = GetIt.instance<MopidyService>();

  _StopButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          try {
            _mopidyService.playback(PlaybackAction.stop, null);
          } catch (e) {
            logger.e(e);
          }
        },
        icon: const Icon(Icons.stop));
  }
}

class _PreviousButton extends StatelessWidget {
  final _mopidyService = GetIt.instance<MopidyService>();

  _PreviousButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          try {
            _mopidyService.playPrevious();
          } catch (e) {
            logger.e(e);
          }
        },
        icon: const Icon(Icons.skip_previous));
  }
}

class _NextButton extends StatelessWidget {
  final _mopidyService = GetIt.instance<MopidyService>();

  _NextButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          try {
            _mopidyService.playNext();
          } catch (e) {
            logger.e(e);
          }
        },
        icon: const Icon(Icons.skip_next));
  }
}
