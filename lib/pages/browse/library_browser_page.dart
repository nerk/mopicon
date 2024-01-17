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
import 'dart:async';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/components/volume_control.dart';
import 'package:mopicon/services/mopidy_service.dart';
import 'package:mopicon/pages/settings/preferences_controller.dart';
import 'package:mopicon/utils/parameters.dart';
import 'package:mopicon/components/action_buttons.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/extensions/mopidy_utils.dart';

import 'library_browser_controller.dart';
import 'library_list_view.dart';
import 'library_appbar_menu.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/components/item_action_dialog.dart';

class LibraryBrowserPage extends StatefulWidget {
  final String? title;
  final String? parent;

  const LibraryBrowserPage({this.title, this.parent, super.key});

  @override
  State<LibraryBrowserPage> createState() => _LibraryBrowserPageState();
}

class _LibraryBrowserPageState extends State<LibraryBrowserPage> {
  Ref? parent;
  List<Ref> items = [];
  var images = <String, Widget>{};

  // selection mode (single/multiple) of track list view
  SelectionMode selectionMode = SelectionMode.off;

  final libraryController = GetIt.instance<LibraryBrowserController>();
  final mopidyService = GetIt.instance<MopidyService>();

  final preferences = GetIt.instance<PreferencesController>();

  StreamSubscription? refreshSubscription;

  Future updateItems() async {
    try {
      mopidyService.setBusy(true);
      if (widget.parent != null) {
        parent = Ref.fromMap(Parameter.fromBase64(widget.parent!));
      }

      items = await libraryController.browse(parent);
      images = await items.getImages();
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      items = [];
      images = {};
    } finally {
      if (mounted) {
        setState(() {});
      }
      mopidyService.setBusy(false);
    }
  }

  void updateSelection() {
    if (mounted) {
      setState(() {
        selectionMode = libraryController.selectionMode;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshSubscription = libraryController.refresh$.listen((_) async {
      await updateItems();
    });

    mopidyService.playlistsChangedNotifier.addListener(updateItems);
    libraryController.selectionModeChanged.addListener(updateSelection);
    libraryController.selectionChanged.addListener(updateSelection);
    updateSelection();
    updateItems();
  }

  @override
  void dispose() {
    refreshSubscription?.cancel();
    libraryController.selectionModeChanged.removeListener(updateSelection);
    libraryController.selectionChanged.removeListener(updateSelection);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (preferences.translateServerNames) {
      translateNames(context);
    }

    var listView = LibraryListView(
        parent, items, images, libraryController.selectionChanged, libraryController.selectionModeChanged,
        (Ref item, int index) async {
      var r = await showActionDialog(
          [ItemActionOption.play, ItemActionOption.addToTracklist, ItemActionOption.addToPlaylist]);
      if (!context.mounted) return;
      switch (r) {
        case ItemActionOption.play:
          await libraryController.addItemsToTracklist<Ref>(context, [item]);
          mopidyService.play(item);
          break;
        case ItemActionOption.addToTracklist:
          await libraryController.addItemsToTracklist<Ref>(context, [item]);
          break;
        case ItemActionOption.addToPlaylist:
          await libraryController.addItemsToPlaylist<Ref>(context, [item]);
          break;
        default:
      }
    }).build();

    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title ?? S.of(context).libraryBrowserPageTitle),
            centerTitle: true,
            leading: widget.parent != null
                ? ActionButton<SelectedItemPositions>(Icons.arrow_back, () {
                    if (libraryController.isSelectionEmpty) {
                      Navigator.of(context).pop();
                    } else {
                      libraryController.notifyUnselect();
                    }
                  })
                : null,
            actions: [
              parent == null
                  ? ActionButton<SelectedItemPositions>(
                      Icons.delete, () => libraryController.deleteSelectedPlaylists(context),
                      valueListenable: libraryController.selectionChanged)
                  : const SizedBox(),
              ActionButton<SelectedItemPositions>(Icons.queue_music, () async {
                var selectedItems = await libraryController.getSelectedItems(parent);
                if (context.mounted) {
                  await libraryController.addItemsToTracklist<Ref>(context, selectedItems);
                }
                libraryController.notifyUnselect();
              }, valueListenable: libraryController.selectionChanged),
              ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
                var selectedItems = await libraryController.getSelectedItems(parent);
                if (context.mounted) {
                  await libraryController.addItemsToPlaylist<Ref>(context, selectedItems);
                }
                libraryController.notifyUnselect();
              }, valueListenable: libraryController.selectionChanged),
              VolumeControl(),
              LibraryBrowserAppBarMenu(items, libraryController)
            ]),
        body: MaterialPageFrame(child: listView));
  }

  void translateNames(BuildContext context) {
    final namesMap = {
      'Files': S.of(context).nameTranslateFiles,
      'Local media': S.of(context).nameTranslateLocalMedia,
      'Albums': S.of(context).nameTranslateAlbums,
      'Artists': S.of(context).nameTranslateArtists,
      'Composers': S.of(context).nameTranslateComposers,
      'Genres': S.of(context).nameTranslateGenres,
      'Performers': S.of(context).nameTranslatePerformers,
      'Release Years': S.of(context).nameTranslateReleaseYears,
      'Tracks': S.of(context).nameTranslateTracks,
      "Last Week's Updates": S.of(context).nameTranslateLastWeeksUpdates,
      "Last Month's Updates": S.of(context).nameTranslateLastMonthsUpdates
    };
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == Ref.typeDirectory) {
        String? translated = namesMap[items[i].name];
        if (translated != null) {
          items[i] = Ref(items[i].uri, translated, items[i].type);
        }
      }
    }
  }
}
