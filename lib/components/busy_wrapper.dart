/*
 * Copyright (c) 2024 Thomas Kern
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
import 'package:mopicon/common/globals.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/services/mopidy_service.dart';

/// Shows a modal busy indicator.
///
/// If [busy] is `true`, interaction with [child] is disabled and
/// a progress indicator is displayed hovering on top of [child].
/// The progress indicator is slowly fading in.
class BusyWrapper extends StatefulWidget {
  final bool busy;
  final Widget child;

  const BusyWrapper(this.child, this.busy, {super.key});

  @override
  State<BusyWrapper> createState() => _BusyWrapperState();
}

class _BusyWrapperState extends State<BusyWrapper> with TickerProviderStateMixin {
  final preferences = GetIt.instance<PreferencesController>();
  final mopidyService = GetIt.instance<MopidyService>();

  double opacity = 0;
  Timer? timer;
  late bool busy;

  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late Animation<double> _connectionAnimation;
  late Animation<double> _busyAnimation;

  void _startAnimation() {
    _stopAnimation();
    timer = Timer(const Duration(milliseconds: 800), () {
      _primaryController.forward(from: 0);
      _secondaryController.forward(from: 0);
      setState(() {
        busy = true;
        opacity = 0.3;
      });
    });
  }

  void _stopAnimation() {
    timer?.cancel();
    _primaryController.reset();
    _secondaryController.reset();
    setState(() {
      busy = false;
      opacity = 0;
    });
  }

  @override
  initState() {
    super.initState();

    _primaryController = AnimationController(duration: const Duration(seconds: 5), vsync: this);

    _secondaryController = AnimationController(duration: const Duration(seconds: 10), vsync: this);

    _connectionAnimation = CurvedAnimation(parent: _secondaryController, curve: Curves.easeIn);

    _busyAnimation = CurvedAnimation(parent: _primaryController, curve: Curves.easeIn);

    busy = widget.busy;
    if (busy) {
      _startAnimation();
    }
  }

  @override
  dispose() {
    timer?.cancel();
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BusyWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update busy state and animations if widget was updated
    if (widget.busy != oldWidget.busy) {
      busy = widget.busy;
      busy ? _startAnimation() : _stopAnimation();
    }
  }

  void stop() async {
    _stopAnimation();
    mopidyService.stop();
    Globals.applicationRoutes.gotoSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!busy && mopidyService.connected) {
      return widget.child;
    }

    return Material(
      child: Stack(
        children: [
          widget.child,
          Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: preferences.theme.data.dialogBackgroundColor),
          ),
          FadeTransition(
            opacity: _busyAnimation,
            child: Center(
              child: Container(padding: const EdgeInsets.all(40), child: const CircularProgressIndicator()),
            ),
          ),
          mopidyService.connected == false
              ? Center(
                  child: FadeTransition(
                    opacity: _connectionAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          S.of(context).connectingPageConnecting,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 100),
                        ElevatedButton(
                          onPressed: stop,
                          child: Text(
                            S.of(context).connectingPageStopBtn,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
