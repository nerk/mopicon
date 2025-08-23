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
import 'package:mopicon/common/base_controller.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/components/menu_builder.dart';
import 'package:mopicon/components/question_dialog.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/pages/playlist/playlist_mixin.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/pages/tracklist/tracklist_mixin.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/utils/logging_utils.dart';

abstract class LibraryBrowserController extends BaseController with TracklistMethods, PlaylistMethods {
  MenuBuilder<Ref> popupMenu(BuildContext? context, Ref? item, int? index);

  Future<List<Ref>> browse(Ref? parent);

  Future<List<Ref>> getSelectedItems(Ref? parent);

  void deleteSelectedPlaylists(BuildContext context);

  Future<void> renamePlayList(BuildContext context, Ref pl, String name);
}

class LibraryBrowserControllerImpl extends LibraryBrowserController {
  final _preferences = GetIt.instance<PreferencesController>();

  var extendedCategoriesNames = ['Performers', 'Release Years', "Last Week's Updates", "Last Month's Updates"];

  @override
  MenuBuilder<Ref> popupMenu(BuildContext? context, Ref? item, int? index) {
    assert(context != null);
    assert(item != null);
    if (item!.type == Ref.typePlaylist) {
      return playlistPopupMenu(context!);
    } else if (item.type == Ref.typeAlbum) {
      return albumPopupMenu(context!);
    } else if (item.type == Ref.typeTrack) {
      return trackPopupMenu(context!);
    } else {
      return MenuBuilder<Ref>();
    }
  }

  MenuBuilder<Ref> albumPopupMenu(BuildContext context) {
    return MenuBuilder<Ref>()
        .addMenuItem(
          S.of(context).menuAddToTracklist,
          Icons.queue_music,
          (_, track, index) => addItemsToTracklist<Ref>(context, [track!]),
        )
        .addMenuItem(
          S.of(context).menuAddToPlaylist,
          Icons.playlist_add,
          (_, track, index) => addItemsToPlaylist<Ref>(context, [track!]),
        )
        .addMenuItem(
          S.of(context).menuDelete,
          Icons.delete,
          deletePlaylist,
          applicableCallback: (track, index) => track.type == Ref.typePlaylist,
        );
  }

  MenuBuilder<Ref> trackPopupMenu(BuildContext context) {
    return MenuBuilder<Ref>()
        .addMenuItem(
          S.of(context).menuAddToTracklist,
          Icons.queue_music,
          (_, track, index) => addItemsToTracklist<Ref>(context, [track!]),
        )
        .addMenuItem(
          S.of(context).menuAddToPlaylist,
          Icons.playlist_add,
          (_, track, index) => addItemsToPlaylist<Ref>(context, [track!]),
        )
        .addMenuItem(
          S.of(context).menuDelete,
          Icons.delete,
          deletePlaylist,
          applicableCallback: (track, index) => track.type == Ref.typePlaylist,
        );
  }

  MenuBuilder<Ref> playlistPopupMenu(BuildContext context) {
    return MenuBuilder<Ref>()
        .addMenuItem(
          S.of(context).menuAddToTracklist,
          Icons.queue_music,
          (_, track, index) => addItemsToTracklist<Ref>(context, [track!]),
        )
        .addMenuItem(S.of(context).menuDelete, Icons.delete, deletePlaylist);
  }

  void deletePlaylist(BuildContext context, Ref? item, int? index) async {
    var deletePlaylistError = S.of(context).deletePlaylistError;
    if (item != null && item.type == Ref.typePlaylist) {
      try {
        var ret = await showQuestionDialog(
          S.of(context).deletePlaylistDialogTitle,
          S.of(context).deletePlaylistDialogMessage(item.name),
          [DialogButtonOption.yes, DialogButtonOption.no],
          defaultOption: DialogButtonOption.no,
        );
        if (ret != null && ret == DialogButtonOption.yes) {
          await mopidyService.deletePlaylist(item);
        }
      } catch (e) {
        logger.e(e);
        showError(deletePlaylistError, null);
      }
    }
  }

  @override
  void deleteSelectedPlaylists(BuildContext context) async {
    var deletePlaylistError = S.of(context).deletePlaylistError;
    List<Ref> selected = await getSelectedItems(null);
    if (!context.mounted) return;
    for (var item in selected) {
      try {
        var ret = await showQuestionDialog(
          S.of(context).deletePlaylistDialogTitle,
          S.of(context).deletePlaylistDialogMessage(item.name),
          [DialogButtonOption.yes, DialogButtonOption.no],
          defaultOption: DialogButtonOption.no,
        );
        if (ret != null && ret == DialogButtonOption.yes) {
          await mopidyService.deletePlaylist(item);
        }
      } catch (e) {
        logger.e(e);
        showError(deletePlaylistError, null);
      }
    }
    notifyUnselect();
  }

  @override
  Future<void> renamePlayList(BuildContext context, Ref pl, String name) async {
    var playlistAlreadyExistsError = S.of(context).playlistAlreadyExistsError;
    var renamePlaylistCreateError = S.of(context).renamePlaylistCreateError;
    try {
      var playlists = await mopidyService.getPlaylists();
      if (name.isNotEmpty) {
        if (playlists.indexWhere((e) => e.name == name) != -1) {
          showError(playlistAlreadyExistsError, null);
        } else {
          await mopidyService.renamePlaylist(pl, name);
        }
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      showError(renamePlaylistCreateError, null);
    }
  }

  @override
  Future<List<Ref>> getSelectedItems(Ref? parent) async {
    var refs = await browse(parent);
    return Future.value(selectionChanged.value.filterSelected(refs));
  }

  @override
  Future<List<Ref>> browse(Ref? parent) async {
    late List<Ref> items;
    items = await mopidyService.browse(parent);
    if (parent == null) {
      // toplevel: show both, media and playlists
      var playlists = await mopidyService.getPlaylists();
      items.addAll(playlists);
    }

    if (parent == null && _preferences.hideFileExtension) {
      items.removeWhere((item) => item.type == Ref.typeDirectory && item.name == 'Files');
    }

    if (!_preferences.showAllMediaCategories) {
      items.removeWhere((item) => item.type == Ref.typeDirectory && extendedCategoriesNames.contains(item.name));
    }
    return items;
  }
}
