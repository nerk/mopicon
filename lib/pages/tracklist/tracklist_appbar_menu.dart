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
import 'package:get_it/get_it.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/components/menu_builder.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/components/new_stream_dialog.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/logging_utils.dart';

import 'tracklist_view_controller.dart';

class TracklistAppBarMenu extends StatelessWidget {
  final TracklistViewController controller;

  const TracklistAppBarMenu(this.controller, {super.key});

  void _selectAll([BuildContext? context, _, __]) async {
    int nTracks = controller.getTrackList().length;
    controller.notifySelectAll(nTracks);
  }

  void _deleteAll(BuildContext context, _, __) {
    final mopidyService = GetIt.instance<MopidyService>();
    controller.notifyUnselect();
    mopidyService.clearTracklist();
  }

  void _newStream(BuildContext context, _, __) async {
    var record = await newStreamDialog(S.of(context).newTracklistStreamDialogTitle);
    if (record != null && context.mounted) {
      try {
        Ref track = Ref(record.uri, record.name, Ref.typeTrack);
        await controller.addItemsToTracklist(context, [track]);
      } catch (e, s) {
        logger.e(e, stackTrace: s);
        if (context.mounted) {
          showError(S.of(context).newStreamCreateError, null);
        }
      }
    }
  }

  void _refresh(BuildContext context, _, __) async {
    controller.notifyRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return MenuBuilder()
        .addMenuItem(S.of(context).menuSelectAll, Icons.select_all, _selectAll)
        .addMenuItem(S.of(context).menuNewStream, Icons.cell_tower, _newStream)
        .addMenuItem(S.of(context).menuClearList, Icons.delete, _deleteAll)
        .addMenuItem(S.of(context).menuRefresh, Icons.refresh, _refresh)
        .addDivider()
        .addSettingsMenuItem(S.of(context).menuSettings)
        .addHelpMenuItem(S.of(context).menuAbout)
        .build(context, null, null);
  }
}
