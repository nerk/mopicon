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

import 'package:get_it/get_it.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseController {
  /// Notification to trigger refresh.
  Stream<bool> get refresh$ => _refresh$.stream;
  final _refresh$ = PublishSubject<bool>();

  final selectionModeChanged = SelectionModeChangedNotifier(SelectionMode.off);
  final selectionChanged = SelectionChangedNotifier(SelectedItemPositions());

  final _mopidyService = GetIt.instance<MopidyService>();

  MopidyService get mopidyService => _mopidyService;
  bool get isSelectionEmpty => selectionChanged.value.isEmpty;
  SelectionMode get selectionMode => selectionModeChanged.value;

  void notifyRefresh() {
    notifyUnselect();
    _refresh$.add(true);
  }

  void notifyUnselect() {
    selectionModeChanged.value = SelectionMode.off;
    selectionChanged.value.isNotEmpty ? selectionChanged.value = SelectedItemPositions() : null;
  }

  void notifySelectAll(int numItems) {
    selectionChanged.value = SelectedItemPositions.all(numItems);
    selectionModeChanged.value = selectionChanged.value.isNotEmpty ? SelectionMode.on : SelectionMode.off;
  }

  void notifySelectPositions(SelectedItemPositions positions) {
    selectionChanged.value = positions;
    selectionModeChanged.value = selectionChanged.value.isNotEmpty ? SelectionMode.on : SelectionMode.off;
  }
}
