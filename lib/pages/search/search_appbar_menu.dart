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
import 'search_view_controller.dart';
import 'package:mopicon/components/menu_builder.dart';
import 'package:mopicon/components/selected_item_positions.dart';
import 'package:mopicon/generated/l10n.dart';

class SearchAppBarMenu extends StatelessWidget {
  final int numberTracks;
  final SearchViewController controller;

  const SearchAppBarMenu(this.numberTracks, this.controller, {super.key});

  void _selectAll(BuildContext? context, _, __) async {
    controller.selectionChanged.value = SelectedItemPositions.all(numberTracks);
    controller.selectionModeChanged.value == SelectionMode.off
        ? SelectionMode.on
        : controller.selectionModeChanged.value;
  }

  @override
  Widget build(BuildContext context) {
    return MenuBuilder()
        .addMenuItem(S.of(context).menuSelectAll, Icons.select_all, _selectAll)
        .addDivider()
        .addSettingsMenuItem(S.of(context).menuSettings)
        .addHelpMenuItem(S.of(context).menuAbout)
        .build(context, null, null);
  }
}
