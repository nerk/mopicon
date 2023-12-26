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

library mopicon.logging;

import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
export 'package:logger/logger.dart';

/// Global logger.
Logger logger = createLogger(kDebugMode ? Level.debug : Level.info);

String getLogMessages() {
  return _logBuffer.toString();
}

void clearLogMessages() {
  _logBuffer.clear();
}

// log buffer
const _maxLen = 20000;
const _minLen = 5000;
StringBuffer _logBuffer = StringBuffer();

Logger createLogger(Level? level) {
  return Logger(
      level: level,
      output: _LoggerOutput(),
      printer: PrettyPrinter(
          lineLength: 120,
          colors: false,
          printEmojis: true,
          methodCount: 2,
          errorMethodCount: 10,
          noBoxingByDefault: true,
          printTime: true));
}

class _LoggerOutput extends LogOutput {
  _LoggerOutput() {
    _logBuffer.clear();
  }

  @override
  void output(OutputEvent event) {
    if (kDebugMode && io.stdout.hasTerminal) {
      for (var line in event.lines) {
        // Send to console
        debugPrint(line);
      }
    }
    // write to buffer
    _logBuffer.write('\n\n');
    _logBuffer.writeAll(event.lines, '\n');
    if (_logBuffer.length > _maxLen) {
      var s = _logBuffer.toString();
      _logBuffer.clear();
      _logBuffer.write(s.substring(s.length - _minLen, s.length));
    }
  }
}
