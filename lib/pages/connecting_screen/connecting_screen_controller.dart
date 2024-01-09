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
import 'package:mopicon/services/preferences_service.dart';

abstract class ConnectingScreenController {
  void connect({int maxRetries});

  void stop();

  bool get retriesExceeded;
}

class ConnectingScreenControllerImpl extends ConnectingScreenController {
  int? _maxRetries;
  int _retries = 0;

  final _mopidyService = GetIt.instance<MopidyService>();
  final _preferences = GetIt.instance<Preferences>();

  ConnectingScreenControllerImpl() {
    void connectionListener(MopidyConnectionState state) async {
      if (state == MopidyConnectionState.reconnecting) {
        _retries++;
      } else if (state == MopidyConnectionState.online) {
        // Search is only supported if the Mopidy-Local extension is
        // enabled for the server. Just set a flag we can
        // check later.
        _preferences.searchSupported = (await _mopidyService.getUriSchemes()).contains('local');
        Globals.applicationRoutes.gotoHome();
      } else {
        Globals.applicationRoutes.gotoConnecting();
      }
    }

    _mopidyService.connectionState$.listen(connectionListener);
  }

  @override
  bool get retriesExceeded => _maxRetries != null && _retries >= _maxRetries!;

  @override
  void connect({int? maxRetries}) async {
    _maxRetries = maxRetries;
    _retries = 0;
    _mopidyService.stop();
    bool success = await _mopidyService.connect(_preferences.url, maxRetries: maxRetries);
    if (!success) {
      Globals.applicationRoutes.gotoSettings();
    }
  }

  @override
  void stop() async {
    _mopidyService.stop();
    Globals.applicationRoutes.gotoSettings();
  }
}
