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
import 'package:flutter/foundation.dart';

extension StreamExtensions<T> on Stream<T> {
  /// Returns a [ValueListenable] for a stream.
  ValueListenable<T> toValueNotifier(T initialValue, {bool Function(T previous, T current)? notifyWhen}) {
    final notifier = ValueNotifier<T>(initialValue);
    listen((value) {
      if (notifyWhen == null || notifyWhen(notifier.value, value)) {
        notifier.value = value;
      }
    });
    return notifier;
  }

  /// Returns a nullable [ValueListenable] for a stream.
  ValueListenable<T?> toNullableValueNotifier({bool Function(T? previous, T? current)? notifyWhen}) {
    final notifier = ValueNotifier<T?>(null);
    listen((value) {
      if (notifyWhen == null || notifyWhen(notifier.value, value)) {
        notifier.value = value;
      }
    });
    return notifier;
  }

  /// Returns a [Listenable] for a stream.
  Listenable toListenable() {
    final notifier = ChangeNotifier();
    listen((_) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifier.notifyListeners();
    });
    return notifier;
  }
}
