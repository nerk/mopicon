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

/// A page that displays a list of radio stations from the Radio Browser API.
class RadioBrowserPage extends StatefulWidget {
  const RadioBrowserPage({super.key});

  @override
  State<RadioBrowserPage> createState() => _RadioBrowserPageState();
}

class _RadioBrowserPageState extends State<RadioBrowserPage> {
  final controller = GetIt.instance<RadioBrowserController>();
  final TextEditingController searchTextEditingController = TextEditingController();
  final TextEditingController countryFilterEditingController = TextEditingController();
  final unselectedCountry = radio.Country(name: "", iso31661: "", stationCount: 0);

  List<radio.Country> countries = [];
  radio.Country? selectedCountry;
  List<radio.Station> stations = [];
  var images = <String, Widget?>{};
  Key dropdownKey = UniqueKey();

  // selection mode (single/multiple) of track list view
  SelectionMode selectionMode = SelectionMode.off;

  // Called when the user wants to reset the station list.
  void resetHandler() async {
    if (mounted) {
      setState(() {
        stations = [];
        selectedCountry = unselectedCountry;
      });
      searchTextEditingController.clear();
    }
  }

  // Called when the selection mode or the selection changes.
  void updateSelection() {
    if (mounted) {
      setState(() {
        selectionMode = controller.selectionMode;
      });
    }
  }

  // Fetches stations from the Radio Browser API and updates the UI.
  void updateStations() async {
    var searchTerm = searchTextEditingController.text;
    if (selectedCountry != unselectedCountry || searchTerm.isNotEmpty) {
      List<radio.Station> rdStations = [];
      try {
        String? country = selectedCountry == unselectedCountry ? null : selectedCountry?.name;
        controller.mopidyService.setBusy(true);
        rdStations = await controller.getStations(country: country, name: searchTerm.isNotEmpty ? searchTerm : null);
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

  // Fetches the list of countries from the Radio Browser API and updates the UI.
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
    searchTextEditingController.dispose();
    countryFilterEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // create dropdown list of all countries
    var dropDownCountries = <DropdownMenuEntry<radio.Country>>[];
    for (final radio.Country country in countries) {
      var countryInfo = controller.getCountryInfo(country.iso31661);
      if (countryInfo != null) {
        dropDownCountries.add(
          DropdownMenuEntry<radio.Country>(
            value: country,
            label: "${countryInfo.displayName} (${country.stationCount})",
            leadingIcon: countryInfo.flag,
          ),
        );
      }
    }
    dropDownCountries = dropDownCountries.sortedBy((e) => e.label);

    var clearIcon = Transform.translate(
      offset: Offset(-5, -5),
      child: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          setState(() {
            selectedCountry = unselectedCountry;
            countryFilterEditingController.clear();
            dropdownKey = UniqueKey();
          });
          updateStations();
        },
      ),
    );

    var listView = RadioBrowserStationListView(stations, controller.selectionChanged, controller.selectionModeChanged, (
      radio.Station station,
      int index,
    ) async {
      var r = await showActionDialog([ItemActionOption.play, ItemActionOption.addToTracklist, ItemActionOption.addToPlaylist]);
      if (!context.mounted) return;
      Ref track = Ref(station.urlResolved ?? station.url, station.name, Ref.typeTrack);
      switch (r) {
        case ItemActionOption.play:
          await controller.addItemsToTracklist(context, [track]);
          controller.mopidyService.play(track);
          break;
        case ItemActionOption.addToTracklist:
          await controller.addItemsToTracklist(context, [track]);
          break;
        case ItemActionOption.addToPlaylist:
          await controller.addItemsToPlaylist(context, [track]);
          break;
        default:
      }
    });

    var pageContent = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        DropdownMenu<radio.Country>(
          key: dropdownKey,
          menuHeight: 400,
          expandedInsets: const EdgeInsets.all(0),
          requestFocusOnTap: true,
          enableSearch: true,
          controller: countryFilterEditingController,
          initialSelection: unselectedCountry,
          label: Text(S.of(context).radioBrowserFilterByCountry),
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints.tight(const Size.fromHeight(48)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),

          dropdownMenuEntries: dropDownCountries,
          onSelected: (radio.Country? country) async {
            if (country != unselectedCountry || searchTextEditingController.text.isNotEmpty) {
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
          selectedTrailingIcon: clearIcon,
          trailingIcon: clearIcon,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: SearchBar(
                controller: searchTextEditingController,
                padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                onSubmitted: (String value) async {
                  updateStations();
                },
                leading: const Icon(Icons.search),
                trailing: <Widget>[
                  IconButton(
                    onPressed: () {
                      searchTextEditingController.clear();
                      updateStations();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(padding: const EdgeInsets.only(top: 12), child: listView),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).radioBrowserTitle),
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
            await controller.addItemsToTracklist(context, stationsAsRef(selectedItems));
            controller.notifyUnselect();
          }, valueListenable: controller.selectionChanged),
          ActionButton<SelectedItemPositions>(Icons.playlist_add, () async {
            var selectedItems = controller.selectionChanged.value.filterSelected(stations);
            await controller.addItemsToPlaylist(context, stationsAsRef(selectedItems));
            controller.notifyUnselect();
          }, valueListenable: controller.selectionChanged),
          VolumeControl(),
          RadioBrowserAppBarMenu(stations.length, controller),
        ],
      ),
      body: MaterialPageFrame(child: pageContent),
    );
  }

  /// Converts a list of [radio.Station] objects to a list of [Ref] objects.
  static List<Ref> stationsAsRef(List<radio.Station> stations) {
    return List.generate(stations.length, (index) {
      return Ref(stations[index].urlResolved ?? stations[index].url, stations[index].name, Ref.typeTrack);
    });
  }
}
