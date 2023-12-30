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
import 'package:mopicon/extensions/timestring.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/globals.dart';
import 'package:mopicon/generated/l10n.dart';

class PlayingProgressIndicator extends StatefulWidget {
  final String playbackState;
  final Duration duration;
  final int timePosition;
  final int bitrate;
  final List<Widget> Function()? buttons;
  final bool isStream;

  const PlayingProgressIndicator(this.duration, this.playbackState,
      this.timePosition, this.bitrate, this.buttons, this.isStream,
      {super.key});

  @override
  State<PlayingProgressIndicator> createState() =>
      _PlayingProgressIndicatorState();
}

class _PlayingProgressIndicatorState extends State<PlayingProgressIndicator>
    with SingleTickerProviderStateMixin {
  final mopidyService = GetIt.instance<MopidyService>();

  late bool isStream;
  late int timePosition;
  late int bitrate;
  late Duration duration;
  late AnimationController controller;
  String? previousPlaybackState;

  @override
  void initState() {
    isStream = widget.isStream;
    timePosition = widget.timePosition;
    bitrate = widget.bitrate;
    duration = widget.duration;
    controller = AnimationController(
      value: timePosition / duration.inMilliseconds,

      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: duration,
    )..addListener(() {
        setState(() {
          timePosition = (duration.inMilliseconds * controller.value).toInt();
        });
      });
    if (widget.playbackState == PlaybackState.playing) {
      controller.forward();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(PlayingProgressIndicator oldWidget) {
    if (widget.playbackState != oldWidget.playbackState) {
      if (widget.playbackState == PlaybackState.paused) {
        controller.stop(canceled: false);
      } else if (widget.playbackState == PlaybackState.stopped) {
        controller.stop(canceled: true);
        controller.reset();
      } else if (widget.playbackState == PlaybackState.playing) {
        controller.forward();
      }
    }
    if (widget.duration != oldWidget.duration) {
      controller.reset();
      controller.duration = widget.duration;
      duration = widget.duration;
      timePosition = widget.timePosition;
      if (widget.playbackState == PlaybackState.playing) {
        controller.forward();
      }
    }

    if (widget.bitrate != oldWidget.bitrate) {
      setState(() {
        bitrate = widget.bitrate;
      });
    }

    if (widget.isStream != oldWidget.isStream) {
      setState(() {
        isStream = widget.isStream;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String cp = timePosition.millisToTimeString();
    String ep = duration.inMilliseconds.millisToTimeString();

    var buttonChilds =
        widget.buttons != null ? [...widget.buttons!()] : [const SizedBox()];
    var buttonRow =
        Row(mainAxisAlignment: MainAxisAlignment.end, children: buttonChilds);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !isStream
              ? Slider(
                  value: controller.value,
                  divisions:
                      duration.inSeconds == 0 ? 5 : duration.inSeconds * 5,
                  //label: cp,
                  onChangeStart: (double value) async {
                    try {
                      previousPlaybackState =
                          await mopidyService.getPlaybackState();
                      if (previousPlaybackState != PlaybackState.stopped) {
                        await mopidyService.playback(
                            PlaybackAction.pause, null);
                      }
                    } catch (e) {
                      Globals.logger.e(e);
                    }
                  },
                  onChanged: widget.playbackState != PlaybackState.stopped
                      ? (double value) {
                          if (previousPlaybackState != PlaybackState.stopped) {
                            controller.value = value;
                          }
                        }
                      : null,
                  onChangeEnd: (double value) async {
                    try {
                      if (previousPlaybackState != PlaybackState.stopped) {
                        var pos = (duration.inMilliseconds * value).toInt();
                        bool success = await mopidyService.seek(pos);
                        if (success) {
                          setState(() {
                            controller.value = value;
                            timePosition = pos;
                          });
                        }
                        if (previousPlaybackState == PlaybackState.playing) {
                          await mopidyService.playback(
                              PlaybackAction.resume, null);
                        }
                      }
                    } catch (e) {
                      Globals.logger.e(e);
                    }
                  },
                )
              : const SizedBox(),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !isStream ? Text('$cp/$ep min') : const SizedBox(),
              bitrate > 0
                  ? Text(S
                      .of(context)
                      .nowPlayingBitrateLbl((bitrate / 1000).round()))
                  : const SizedBox(),
              buttonRow
            ],
          )
        ]);
  }
}
