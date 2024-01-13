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

double _defaultTop = 15;
double _defaultBottom = 15;

/// A [Divider] with a leading text and vertical spacing.
class TitledDivider extends StatelessWidget {
  final String title;

  /// Creates a [Divider] with a leading title and additional vertical spacing.
  const TitledDivider(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: _defaultTop, bottom: _defaultBottom),
        child: Row(children: <Widget>[
          Text(title),
          Expanded(
            child: Container(margin: const EdgeInsets.only(left: 10.0), child: const Divider()),
          ),
        ]));
  }
}

/// A [Divider] with a leading text and vertical spacing.
class SpacedDivider extends StatelessWidget {
  /// Creates a [Divider] with additional vertical spacing.
  const SpacedDivider({super.key});

  @override
  build(BuildContext context) {
    return Container(margin: EdgeInsets.only(top: _defaultTop, bottom: _defaultBottom), child: const Divider());
  }
}

/// A vertical spaced.
class VerticalSpacer extends StatelessWidget {
  final double? space;

  /// Creates a [Divider] with additional vertical spacing.
  const VerticalSpacer({this.space, super.key});

  @override
  build(BuildContext context) {
    var vsp = space ?? _defaultTop + _defaultBottom;
    return Container(
      margin: EdgeInsets.only(top: vsp / 2.0, bottom: vsp / 2),
    );
  }
}
