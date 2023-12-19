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
import 'package:mopicon/services/mopidy_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/utils/globals.dart';

abstract class ConnectingScreenController {
  void connect({int maxRetries});

  void stop();

  bool get connecting;

  bool get connected;

  bool get retriesExceeded;
}

class ConnectingScreenControllerImpl extends ConnectingScreenController {
  int _maxRetries = 0;

  final _mopidyService = GetIt.instance<MopidyService>();

  bool _connecting = false;
  var _retries = 0;

  ConnectingScreenControllerImpl() {
    void connectionListener() async {
      if (_mopidyService.stopped) {
        return;
      }

      ClientStateInfo stateInfo = _mopidyService.connectionNotifier.value;
      if (stateInfo.state == ClientState.reconnecting) {
        if (_maxRetries > 0) {
          _retries++;
          if (_retries > _maxRetries) {
            stop();
          }
        }
      } else if (stateInfo.state == ClientState.offline) {
        _retries = 0;
      }

      if (stateInfo.state == ClientState.online) {
        // Search is only supported if the Mopidy-Local extension is
        // enabled for the server. Just set a flag we can
        // check later.
        Globals.preferences.searchSupported =
            (await _mopidyService.getUriSchemes()).contains('local');
        _connecting = false;
        Globals.applicationRoutes.gotoHome();
      } else if (stateInfo.state == ClientState.offline && !_connecting) {
        _connecting = true;
        Globals.applicationRoutes.gotoConnecting(_maxRetries);
      }
    }

    _mopidyService.connectionNotifier.addListener(connectionListener);
  }

  @override
  bool get connecting => _connecting;

  @override
  bool get retriesExceeded => _maxRetries != 0 && _retries > _maxRetries;

  @override
  void connect({int maxRetries = 0}) {
    _maxRetries = maxRetries;
    _mopidyService.stop();
    _mopidyService.connect();
  }

  @override
  bool get connected => _mopidyService.connected;

  @override
  void stop() async {
    _connecting = false;
    _mopidyService.stop();
    Globals.applicationRoutes.gotoSettings();
  }
}
