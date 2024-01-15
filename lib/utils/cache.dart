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

int _ageCounter = 0;

class _CacheItem<E> {
  late int _age;
  final String key;
  final E data;

  _CacheItem(this.key, this.data) {
    _age = _ageCounter++;
  }

  @override
  String toString() => "$key: $data (age = $_age)";
}

class Cache<E> {
  final int maxSize;
  final int minSize;

  Cache(this.minSize, this.maxSize) {
    assert(maxSize > minSize + 2 * ((maxSize * 0.2).toInt()));
  }

  final _cache = <String, _CacheItem<E>>{};

  void _shrink() {
    var sortedValues = _cache.values.toList()..sort((e1, e2) => e1._age.compareTo(e2._age));
    int nr = (maxSize * 0.2).toInt(); // shrink by 20%
    // remove nr items which were accessed least
    for (int i = 0; i < nr; i++) {
      _cache.remove(sortedValues[i].key);
    }
  }

  void clear() {
    _cache.clear();
  }

  void put(String key, E value) {
    _cache.update(key, (v) => _CacheItem(key, value), ifAbsent: () => _CacheItem<E>(key, value));
    if (_cache.length >= maxSize) {
      _shrink();
    }
  }

  void putAll(Map<String, E> data) {
    for (var entry in data.entries) {
      put(entry.key, entry.value);
    }
  }

  E? get(String key) {
    var item = _cache[key];
    if (item != null) {
      item._age = _ageCounter++;
    }
    return item?.data;
  }

  bool contains(String key) {
    return _cache[key] != null ? true : false;
  }

  bool get isEmpty => _cache.isEmpty;

  bool get isNotEmpty => _cache.isNotEmpty;

  int get size => _cache.length;

  @override
  String toString() => _cache.toString();
}
