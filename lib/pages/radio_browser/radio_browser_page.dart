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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/common/selected_item_positions.dart';
import 'package:mopicon/components/action_buttons.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/components/item_action_dialog.dart';
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/components/volume_control.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;
import 'package:mopidy_client/mopidy_client.dart';

import 'radio_browser_appbar_menu.dart';
import 'radio_browser_controller.dart';
import 'radio_browser_station_view.dart';

class RadioBrowserPage extends StatefulWidget {
  const RadioBrowserPage({super.key});

  @override
  State<RadioBrowserPage> createState() => _RadioBrowserPageState();
}

class _RadioBrowserPageState extends State<RadioBrowserPage> {
  final controller = GetIt.instance<RadioBrowserController>();
  final TextEditingController textEditingController = TextEditingController();
  final unselectedCountry = radio.Country(name: "", iso31661: "", stationCount: 0);

  List<radio.Country> countries = [];
  radio.Country? selectedCountry;
  List<radio.Station> stations = [];
  String? searchTerm;
  var images = <String, Widget?>{};

  // selection mode (single/multiple) of track list view
  SelectionMode selectionMode = SelectionMode.off;

  void resetHandler() async {
    if (mounted) {
      setState(() {
        searchTerm = null;
        stations = [];
        selectedCountry = unselectedCountry;
      });
      textEditingController.clear();
    }
  }

  void updateSelection() {
    if (mounted) {
      setState(() {
        selectionMode = controller.selectionMode;
      });
    }
  }

  void updateStations() async {
    if (selectedCountry != unselectedCountry || searchTerm != null) {
      List<radio.Station> rdStations = [];
      try {
        String? country = selectedCountry == unselectedCountry ? null : selectedCountry?.name;
        controller.mopidyService.setBusy(true);
        rdStations = await controller.getStations(country: country, name: searchTerm);
      } catch (e, s) {
        logger.e(e, stackTrace: s);
        rdStations = [];
      } finally {
        controller.mopidyService.setBusy(false);
        setState(() {
          stations = rdStations;
        });
      }
    } else {
      setState(() {
        stations = [];
      });
    }
  }

  void initCountries() async {
    var cntrs = List<radio.Country>.empty(growable: true);
    cntrs.add(unselectedCountry);
    try {
      controller.mopidyService.setBusy(true);
      var result = await controller.getCountries();
      cntrs.addAll(result);
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      countries = cntrs;
    } finally {
      controller.mopidyService.setBusy(false);
      if (mounted) {
        //print(cntrs.sortedBy((c) => c.iso31661).map((c) => c.iso31661).toList());
        setState(() {
          countries = cntrs.sortedBy((c) => c.name);
          selectedCountry = unselectedCountry;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller.selectionModeChanged.addListener(updateSelection);
    controller.selectionChanged.addListener(updateSelection);
    controller.resetNotifier.addListener(resetHandler);
    initCountries();
    updateSelection();
  }

  @override
  void dispose() {
    controller.selectionModeChanged.removeListener(updateSelection);
    controller.selectionChanged.removeListener(updateSelection);
    controller.resetNotifier.removeListener(resetHandler);
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    // create dropdown list of all countries
    final List<DropdownMenuEntry<radio.Country>> dropDownCountries = <DropdownMenuEntry<radio.Country>>[];
    for (final radio.Country country in countries) {
      dropDownCountries.add(
        DropdownMenuEntry<radio.Country>(
          value: country,
          label: country.name,
          //leadingIcon: Container(width: 20, height: 20, color: theme.data.colorScheme.primaryContainer),
        ),
      );
    }

    var listView = RadioBrowserStationListView(stations, controller.selectionChanged, controller.selectionModeChanged, (
      radio.Station station,
      int index,
    ) async {
      var r = await showActionDialog([ItemActionOption.play, ItemActionOption.addToTracklist, ItemActionOption.addToPlaylist]);
      if (!context.mounted) return;
      print(stations[index].urlResolved);
      print(stations[index].url);
        Ref track = Ref(station.urlResolved ?? station.url, station.name, Ref.typeTrack);
        switch (r) {
          case ItemActionOption.play:
            await controller.addItemsToTracklist<Ref>(context, [track]);
            controller.mopidyService.play(track);
            break;
          case ItemActionOption.addToTracklist:
            await controller.addItemsToTracklist<Ref>(context, [track]);
            break;
          case ItemActionOption.addToPlaylist:
            await controller.addItemsToPlaylist<Ref>(context, [track]);
            break;
          default:
        }
    });

    var pageContent = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SearchBar(
          controller: textEditingController,
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
          onSubmitted: (String value) async {
            searchTerm = value;
            updateStations();
          },
          leading: const Icon(Icons.search),
          trailing: <Widget>[
            IconButton(
              onPressed: () {
                searchTerm = null;
                textEditingController.clear();
                updateStations();
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        DropdownMenu<radio.Country>(
          expandedInsets: const EdgeInsets.only(left: 30),
          requestFocusOnTap: false,
          initialSelection: selectedCountry,
          label: Text(S.of(context).preferencesPageThemeLbl),
          dropdownMenuEntries: dropDownCountries,
          onSelected: (radio.Country? country) async {
            if (country != unselectedCountry || searchTerm != null) {
              setState(() {
                selectedCountry = country;
              });
              updateStations();
            } else {
              setState(() {
                selectedCountry = unselectedCountry;
                stations = [];
              });
            }
          },
        ),
        Expanded(
          child: Padding(padding: const EdgeInsets.only(top: 12), child: listView),
        ),
      ],
    );

    var notSupported = Center(
      child: Text(S.of(context).searchPageNotSupportedMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).searchPageTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        leading: controller.selectionChanged.value.isNotEmpty
            ? ActionButton<SelectedItemPositions>(Icons.arrow_back, () {
                controller.notifyUnselect();
              })
            : null,
        actions: [
          ActionButton<SelectedItemPositions>(Icons.queue_music, () async {
            var selectedItems = controller.selectionChanged.value.filterSelected(stations);
            await controller.addItemsToTracklist<Ref>(context, stationsAsRef(selectedItems));
            controller.notifyUnselect();
          }, valueListenable: controller.selectionChanged),
          ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
            var selectedItems = controller.selectionChanged.value.filterSelected(stations);
            await controller.addItemsToPlaylist<Ref>(context, stationsAsRef(selectedItems));
            controller.notifyUnselect();
          }, valueListenable: controller.selectionChanged),
          VolumeControl(),
          RadioBrowserAppBarMenu(stations.length, controller),
        ],
      ),
      body: MaterialPageFrame(child: pageContent),
    );
  }

  static List<Ref> stationsAsRef(List<radio.Station> stations) {
    return List.generate(stations.length, (index) {
      //return Ref(stations[index].urlResolved ?? stations[index].url, stations[index].name, Ref.typeTrack);
      print(stations[index].urlResolved);
      print(stations[index].url);
      return Ref(stations[index].urlResolved ?? stations[index].url, stations[index].name, Ref.typeTrack);
    });
  }
}
