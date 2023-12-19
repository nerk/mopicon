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
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/globals.dart';
import 'package:get_it/get_it.dart';

/// Volume control an muting for Mopidy server.
class VolumeControl extends StatefulWidget {
  VolumeControl() : super(key: UniqueKey());

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'VolumeControl');
  final _mopidyService = GetIt.instance<MopidyService>();

  var volume = 0;
  var muted = false;

  void mutedChangedCallback() {
    setState(() {
      muted = _mopidyService.muteChangedNotifier.value;
    });
  }

  void volumeChangedCallback() {
    setState(() {
      volume = _mopidyService.volumeChangedNotifier.value;
    });
  }

  void updateState() async {
    try {
      var m = await _mopidyService.isMuted() ?? false;
      var v = await _mopidyService.getVolume() ?? 0;
      if (mounted) {
        setState(() {
          muted = m;
          volume = v;
        });
      }
    } catch (e) {
      Globals.logger.e(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _mopidyService.volumeChangedNotifier.addListener(volumeChangedCallback);
    _mopidyService.muteChangedNotifier.addListener(mutedChangedCallback);
    updateState();
  }

  @override
  void dispose() {
    _mopidyService.volumeChangedNotifier.removeListener(volumeChangedCallback);
    _mopidyService.muteChangedNotifier.removeListener(mutedChangedCallback);
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MenuAnchor(
              childFocusNode: _buttonFocusNode,
              menuChildren: <Widget>[
                Row(children: <Widget>[
                  IconButton(
                    icon: muted
                        ? const Icon(Icons.volume_off)
                        : const Icon(Icons.volume_up),
                    focusNode: _buttonFocusNode,
                    onPressed: () async {
                      var m = !muted;
                      setState(() {
                        muted = m;
                      });
                      try {
                        await _mopidyService.setMute(m);
                      } catch (e) {
                        Globals.logger.e(e);
                      }
                    },
                  ),
                  Slider(
                    min: 0.0,
                    max: 100.0,
                    value: volume.toDouble(),
                    label: volume.round().toString(),
                    divisions: 100,
                    onChangeEnd: (double value) async {
                      try {
                        await _mopidyService.setVolume(value.toInt());
                        setState(() {
                          volume = value.toInt();
                        });
                      } catch (e) {
                        Globals.logger.e(e);
                      }
                    },
                    onChanged: (double value) {
                      setState(() {
                        volume = value.toInt();
                      });
                    },
                  )
                ])
              ],
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return IconButton(
                  icon: muted
                      ? const Icon(Icons.volume_off)
                      : const Icon(Icons.volume_up),
                  focusNode: _buttonFocusNode,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      //updateState();
                      controller.open();
                    }
                  },
                );
              }),
        ]);
  }
}
