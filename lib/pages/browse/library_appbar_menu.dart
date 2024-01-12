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
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/pages/browse/library_browser_controller.dart';
import 'package:mopicon/pages/browse/rename_playlist_dialog.dart';
import 'package:mopicon/pages/browse/new_playlist_dialog.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/components/menu_builder.dart';
import 'package:mopicon/common/globals.dart';

class LibraryBrowserAppBarMenu extends StatelessWidget {
  final mopidyService = GetIt.instance<MopidyService>();

  final List<Ref> items;
  final LibraryBrowserController controller;

  LibraryBrowserAppBarMenu(this.items, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    late var menuBuilder = MenuBuilder();
    if (items.indexWhere((e) => e.type != Ref.typeTrack) == -1) {
      menuBuilder.addMenuItem(S.of(context).menuSelectAll, Icons.select_all, _selectAll);
    }

    controller.selectionChanged.value.positions.length != 1
        ? menuBuilder.addMenuItem(S.of(context).menuNewPlaylist, Icons.playlist_add, _newPlayList)
        : menuBuilder.addMenuItem(S.of(context).menuRenamePlaylist, Icons.drive_file_rename_outline, _renamePlayList);

    return menuBuilder
        .addMenuItem(S.of(context).menuRefresh, Icons.refresh, _refresh)
        .addDivider()
        .addSettingsMenuItem(S.of(context).menuSettings)
        .addHelpMenuItem(S.of(context).menuAbout)
        .build(context, null, null);
  }

  void _selectAll([BuildContext? context, _, __]) async {
    controller.notifySelectAll(items.length);
  }

  void _newPlayList(BuildContext? context, _, __) {
    mopidyService.getPlaylists().then((List<Ref> playlists) {
      newPlaylistDialog().then((name) {
        if (name != null && name.isNotEmpty) {
          mopidyService.createPlaylist(name).then((playlist) {
            if (playlist == null) {
              showError(S.of(context!).playlistAlreadyExistsError, null);
            }
          }).onError((e, s) {
            Globals.logger.e(e, stackTrace: s);
            showError(S.of(context!).newPlaylistCreateError, null);
          });
        }
      });
    });
  }

  void _renamePlayList(BuildContext context, _, __) async {
    if (controller.selectionChanged.value.positions.length == 1) {
      var ref = items[controller.selectionChanged.value.positions.first];
      controller.notifyUnselect();
      var name = await renamePlaylistDialog(ref.name);
      if (name != null) {
        if (context.mounted) {
          await controller.renamePlayList(context, ref, name);
        }
      }
    }
  }

  void _refresh(BuildContext context, _, __) {
    controller.notifyRefresh();
  }
}
