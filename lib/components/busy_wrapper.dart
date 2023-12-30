import 'package:flutter/material.dart';
import 'package:mopicon/utils/globals.dart';

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
  State<BusyWrapper> createState() => BusyWrapperState();
}

class BusyWrapperState extends State<BusyWrapper>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  bool _busy = false;

  bool get busy => _busy;

  set busy(bool b) {
    setState(() {
      b ? _controller.forward() : _controller.reset();
      _busy = b;
    });
  }

  @override
  initState() {
    super.initState();
    _busy = widget.busy;
    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BusyWrapper oldWidget) {
    _controller.reset();
    _controller.forward();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.busy) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Opacity(
          opacity: 0.4,
          child: ModalBarrier(
              dismissible: false,
              color: Globals.preferences.theme.data.dialogBackgroundColor),
        ),
        Center(
          child: FadeTransition(
            opacity: _animation,
            child: const CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
