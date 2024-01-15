import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/common/globals.dart';
import 'package:mopicon/generated/l10n.dart';

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

  late final AnimationController _primaryController = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  );

  late final AnimationController _secondaryController = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  );

  late final Animation<double> _connectionAnimation = CurvedAnimation(
    parent: _secondaryController,
    curve: Curves.easeIn,
  );

  late final Animation<double> _busyAnimation = CurvedAnimation(
    parent: _primaryController,
    curve: Curves.easeIn,
  );

  void _startAnimation() {
    _stopAnimation();
    timer = Timer(const Duration(milliseconds: 800), () {
      _primaryController.forward(from: 0);
      _secondaryController.forward(from: 0);
      setState(() {
        opacity = 0.3;
      });
    });
  }

  void _stopAnimation() {
    opacity = 0;
    timer?.cancel();
    _primaryController.reset();
    _secondaryController.reset();
  }

  @override
  initState() {
    super.initState();
    _startAnimation();
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
    _startAnimation();
    super.didUpdateWidget(oldWidget);
  }

  void stop() async {
    _stopAnimation();
    mopidyService.stop();
    Globals.applicationRoutes.gotoSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.busy && mopidyService.connected) {
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
          child: Center(child: Container(padding: const EdgeInsets.all(40), child: const CircularProgressIndicator())),
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
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                          onPressed: stop,
                          child: Text(S.of(context).connectingPageStopBtn,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)))
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ],
    ));
  }
}
