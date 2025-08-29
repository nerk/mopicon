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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:dnsolve/dnsolve.dart';
import 'package:mopicon/common/base_controller.dart';
import 'package:mopicon/pages/playlist/playlist_mixin.dart';
import 'package:mopicon/pages/tracklist/tracklist_mixin.dart';
import 'package:mopicon/utils/logging_utils.dart';
import 'package:mopicon/utils/open_value_notifier.dart';

const _hostLookup = "_api._tcp.radio-browser.info";

typedef RadioBrowserCountriesChanged = ValueNotifier<List<Country>>;
typedef RadioBrowserStationsChanged = ValueNotifier<List<Station>>;

abstract class RadioBrowserController extends BaseController with TracklistMethods, PlaylistMethods {

  /// Notification to trigger refresh.
  var resetNotifier = OpenValueNotifier<bool>(false);

  var countriesChanged = RadioBrowserCountriesChanged([]);
  var stationsChanged = RadioBrowserStationsChanged([]);

  Future<List<String>> getRadiobrowserHosts();
  Future<List<Country>> getCountries();
  Future<List<Station>> getStations({String? country, String? name, bool? nameExact});
  void reset();
  void listAll();
}

class RadioBrowserControllerImpl extends RadioBrowserController {

  RadioBrowserApi? _api;

  Future<RadioBrowserApi> getApi() async {
    if (_api != null) {
      return _api!;
    }
    return await _retrieveApi();
  }

  @override
  Future<List<String>> getRadiobrowserHosts() async {
    final dnsolve = DNSolve();
    final response = await dnsolve.lookup(_hostLookup, dnsSec: true, type: RecordType.srv);

    final records = response.answer?.srvs;
    if (records == null) {
      return [];
    }

    // Hostnames in r.target seem to come with an extra . at the end, which must be removed
    final hosts = records.map((r) => r.target?.substring(0, r.target!.length - 1)).nonNulls.toList();
    hosts.sort();
    return hosts;
  }

  Future<RadioBrowserApi> _retrieveApi() async {
    var hosts = await getRadiobrowserHosts();
    var idx = Random().nextInt(hosts.length);
    for (var i = 0; i < hosts.length; i++) {
      var api = RadioBrowserApi.fromHost(hosts[idx]);
      try {
        // test api
        await api.getCodecs();
        return api;
      } catch (e) {
        if (idx < hosts.length - 1) {
          idx++;
        } else {
          idx = 0;
        }
      }
    }
    // TODO
    throw Exception("Could not retrieve RadioBrowser API");
  }

  void _checkResponse(RadioBrowserListResponse response) {
    // TODO
    if (response.statusCode != 200) {
        logger.e(response.statusCode);
        throw Exception(response.error);
    }
  }

  @override
  Future<List<Country>> getCountries() async {
    RadioBrowserApi api = await getApi();
    var response = await api.getCountries();
    _checkResponse(response);
    return response.items;
  }

  @override
  Future<List<Station>> getStations({String? country, String? name, bool? nameExact = false}) async {
    const hideBroken = InputParameters(hidebroken: true, order: 'name');
    RadioBrowserApi api = await getApi();
    RadioBrowserListResponse<Station> response;
    if (country == null && name == null) {
      response = await api.getAllStations(parameters: hideBroken);
    } else if (country != null && name == null){
      response = await api.getStationsByCountry(country: country, parameters: hideBroken);
    } else {
      response = await api.advancedStationSearch(country: country, name: name, nameExact: nameExact, parameters: hideBroken);
    }
    _checkResponse(response);

    var stations = response.items.map((e) {
      if (e.lastCheckOk) {
        // TODO: Mopidy cannot handle HLS streams yet.
        //if (!e.url.endsWith('.m3u8')) {
          //return e;
        //}
        return e;
      }
      return null;
    }).nonNulls.toList();
    return stations;
  }

  @override
  void listAll() async {
    try {
      var countries = await getCountries();
      print(countries.map((e) => e.name).toList());

      //var stations = await getStations(country: "Germany", name: "Hochstift");
      var stations = await getStations(country: "The United States Of America", name: "106");
      print(stations.map((e) => e.name).toList());
      print(stations.length);
    } catch (e) {
      print(e);
    }
  }

  @override
  void reset() async {
    resetNotifier.notify();
  }
}
