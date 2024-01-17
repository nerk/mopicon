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

enum SelectionMode { on, off }

typedef SelectionChangedNotifier = ValueNotifier<SelectedItemPositions>;
typedef SelectionModeChangedNotifier = ValueNotifier<SelectionMode>;

typedef SelectionPositions = Set<int>;

class SelectedItemPositions {
  SelectionPositions _positions = {};

  SelectedItemPositions();

  SelectedItemPositions.all(int len) {
    for (int i = 0; i < len; i++) {
      _positions.add(i);
    }
  }

  List<T> filterSelected<T>(List<T> items) {
    return [for (var pos in positions) items[pos]];
  }

  List<T> removeSelected<T>(List<T> items) {
    List<T> filtered = List<T>.empty(growable: true);
    if (positions.isNotEmpty) {
      for (var i = 0; i < items.length; i++) {
        if (!positions.contains(i)) {
          filtered.add(items[i]);
        }
      }
    }
    return filtered;
  }

  SelectedItemPositions clone() {
    return SelectedItemPositions()..positions = _positions;
  }

  SelectionPositions get positions => _positions;

  set positions(SelectionPositions pos) {
    _positions = Set<int>.from(pos);
  }

  bool get isEmpty => _positions.isEmpty;

  bool get isNotEmpty => _positions.isNotEmpty;

  bool set(int index) {
    return _positions.add(index);
  }

  bool clear(int index) {
    return _positions.remove(index);
  }

  void clearAll() {
    _positions.clear();
  }

  bool isSet(int index) {
    return _positions.contains(index);
  }

  bool toggle(int index) {
    if (isSet(index)) {
      clear(index);
    } else {
      set(index);
    }
    return _positions.contains(index);
  }

  void move(int start, int current, int length) {
    var selected = _selectedFromPositions(length);
    if (start < current) {
      selected.insert(current, selected[start]);
      selected.removeAt(start);
    } else {
      selected.insert(current, selected.removeAt(start));
    }
    _positionsFromSelected(selected);
  }

  List<bool> _selectedFromPositions(int length) {
    var selected = List<bool>.filled(length, false, growable: true);
    for (var pos in _positions) {
      if (pos < length) {
        selected[pos] = true;
      }
    }
    return selected;
  }

  void _positionsFromSelected(List<bool> selected) {
    _positions = {};
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        _positions.add(i);
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      other is SelectedItemPositions && other.runtimeType == runtimeType && other.positions == positions;

  @override
  int get hashCode => positions.hashCode;

  @override
  String toString() {
    return positions.toString();
  }
}
