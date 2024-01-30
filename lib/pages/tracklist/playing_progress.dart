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
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/extensions/timestring.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/logging_utils.dart';

class PlayingProgressIndicator extends StatefulWidget {
  final String playbackState;
  final Duration duration;
  final int timePosition;
  final int bitrate;
  final List<Widget> Function()? buttons;
  final bool isStream;

  const PlayingProgressIndicator(
      this.duration, this.playbackState, this.timePosition, this.bitrate, this.buttons, this.isStream,
      {super.key});

  @override
  State<PlayingProgressIndicator> createState() => _PlayingProgressIndicatorState();
}

class _PlayingProgressIndicatorState extends State<PlayingProgressIndicator> with SingleTickerProviderStateMixin {
  final mopidyService = GetIt.instance<MopidyService>();

  late bool isStream;
  late int bitrate;

  late String playbackState;

  late ProgressController ticker;

  String? previousPlaybackState;

  // Update Position on seeked event
  void trackSeekedListener() {
    setState(() {
      ticker.time = mopidyService.seekedNotifier.value;
      if (playbackState == PlaybackState.playing) {
        ticker.start();
      } else {
        ticker.pause();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    mopidyService.seekedNotifier.addListener(trackSeekedListener);
    isStream = widget.isStream;
    bitrate = widget.bitrate;
    playbackState = widget.playbackState;

    ticker = ProgressController((pos) {
      setState(() {});
    });
    ticker.duration = widget.duration;
    ticker.time = widget.timePosition;
    if (playbackState == PlaybackState.playing) {
      ticker.start();
    }
  }

  @override
  void didUpdateWidget(PlayingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timePosition != oldWidget.timePosition) {
      ticker.time = widget.timePosition;
    }

    if (widget.duration != oldWidget.duration) {
      ticker.duration = widget.duration;
    }

    if (widget.bitrate != oldWidget.bitrate) {
      bitrate = widget.bitrate;
    }

    if (widget.isStream != oldWidget.isStream) {
      isStream = widget.isStream;
    }

    if (widget.playbackState != oldWidget.playbackState) {
      playbackState = widget.playbackState;
    }

    if (widget.playbackState != oldWidget.playbackState || widget.playbackState == PlaybackState.playing) {
      if (widget.playbackState == PlaybackState.paused) {
        ticker.pause();
      } else if (widget.playbackState == PlaybackState.stopped) {
        ticker.cancel();
      } else if (widget.playbackState == PlaybackState.playing) {
        ticker.start();
      }
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    mopidyService.seekedNotifier.removeListener(trackSeekedListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var slider = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max, children: [
      Text(ticker.timeLabel),
      Expanded(
          child: Slider(
        value: ticker.sliderValue,
        onChangeStart: (double value) async {
          try {
            previousPlaybackState = await mopidyService.getPlaybackState();
            ticker.pause();
          } catch (e) {
            logger.e(e);
          }
        },
        onChanged: (double value) {
          setState(() {
            ticker.sliderValue = value;
          });
        },
        onChangeEnd: (double value) async {
          try {
            var pos = ticker.positionFromSliderValue(value);
            bool success = await mopidyService.seek(pos);
            if (success) {
              ticker.sliderValue = value;
              // needs restart because 'seek' stops player.
              if (previousPlaybackState == PlaybackState.playing) {
                ticker.start();
                await mopidyService.playback(PlaybackAction.resume, null);
              }
              setState(() {});
            }
          } catch (e) {
            logger.e(e);
          }
        },
      )),
      Text(ticker.durationLabel),
    ]);

    var buttons = widget.buttons != null ? [...widget.buttons!()] : [const SizedBox()];
    var buttonRow = Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons);
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [!isStream || widget.duration.inMilliseconds > 0 ? slider : const SizedBox(), buttonRow]);
  }
}

class ProgressController {
  int _fromTime = 0;
  int _time = 0;
  Duration duration = const Duration();
  late Ticker _ticker;
  late void Function(int position) callback;

  ProgressController(void Function(int position) cb) {
    callback = cb;
    _ticker = Ticker((Duration elapsed) {
      _time = _fromTime + elapsed.inMilliseconds;
      cb(_time);
    });
  }

  double get sliderValue => duration.inMilliseconds > 0 ? _time / duration.inMilliseconds : 0;

  set sliderValue(double value) {
    _fromTime = (duration.inMilliseconds * value).toInt();
    _time = _fromTime;
  }

  int get time => _time;

  set time(int value) {
    _time = _fromTime = value;
    callback(_time);
  }

  String get timeLabel => _time.millisToTimeString();

  String get durationLabel => duration.inMilliseconds.millisToTimeString();

  void start() {
    _fromTime = _time;
    _ticker.stop();
    _ticker.start();
  }

  void pause() {
    _fromTime = _time;
    _ticker.stop();
  }

  void cancel() {
    _fromTime = _time;
    _ticker.stop(canceled: true);
  }

  void dispose() {
    _ticker.dispose();
  }

  int positionFromSliderValue(double value) {
    return (duration.inMilliseconds * value).toInt();
  }
}
