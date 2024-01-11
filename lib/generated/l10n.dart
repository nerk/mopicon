// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Mopicon`
  String get appName {
    return Intl.message(
      'Mopicon',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get okBtn {
    return Intl.message(
      'OK',
      name: 'okBtn',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelBtn {
    return Intl.message(
      'Cancel',
      name: 'cancelBtn',
      desc: '',
      args: [],
    );
  }

  /// `Abort`
  String get abortBtn {
    return Intl.message(
      'Abort',
      name: 'abortBtn',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesBtn {
    return Intl.message(
      'Yes',
      name: 'yesBtn',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get noBtn {
    return Intl.message(
      'No',
      name: 'noBtn',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retryBtn {
    return Intl.message(
      'Retry',
      name: 'retryBtn',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submitBtn {
    return Intl.message(
      'Submit',
      name: 'submitBtn',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveBtn {
    return Intl.message(
      'Save',
      name: 'saveBtn',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get connectingPageConnecting {
    return Intl.message(
      'Connecting...',
      name: 'connectingPageConnecting',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get connectingPageStopBtn {
    return Intl.message(
      'Stop',
      name: 'connectingPageStopBtn',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get homePageSearchLbl {
    return Intl.message(
      'Search',
      name: 'homePageSearchLbl',
      desc: '',
      args: [],
    );
  }

  /// `Browse`
  String get homePageBrowseLbl {
    return Intl.message(
      'Browse',
      name: 'homePageBrowseLbl',
      desc: '',
      args: [],
    );
  }

  /// `Tracks`
  String get homePageTracksLbl {
    return Intl.message(
      'Tracks',
      name: 'homePageTracksLbl',
      desc: '',
      args: [],
    );
  }

  /// `Page not found!`
  String get pageNotFoundMsg {
    return Intl.message(
      'Page not found!',
      name: 'pageNotFoundMsg',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get preferencesPageTitle {
    return Intl.message(
      'Settings',
      name: 'preferencesPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `IP address or hostname of Mopidy server.`
  String get preferencesPageMopidyServerHintText {
    return Intl.message(
      'IP address or hostname of Mopidy server.',
      name: 'preferencesPageMopidyServerHintText',
      desc: '',
      args: [],
    );
  }

  /// `Mopidy server *`
  String get preferencesPageMopidyServerLblText {
    return Intl.message(
      'Mopidy server *',
      name: 'preferencesPageMopidyServerLblText',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid hostname or IP address.`
  String get preferencesPageMopidyServerInvalid {
    return Intl.message(
      'Please enter a valid hostname or IP address.',
      name: 'preferencesPageMopidyServerInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Port of Mopidy server.`
  String get preferencesPageMopidyPortHintText {
    return Intl.message(
      'Port of Mopidy server.',
      name: 'preferencesPageMopidyPortHintText',
      desc: '',
      args: [],
    );
  }

  /// `Mopidy server port *`
  String get preferencesPageMopidyPortLblText {
    return Intl.message(
      'Mopidy server port *',
      name: 'preferencesPageMopidyPortLblText',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid port number.`
  String get preferencesPageMopidyPortInvalid {
    return Intl.message(
      'Please enter a valid port number.',
      name: 'preferencesPageMopidyPortInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Connection`
  String get preferencesPageConnectionLbl {
    return Intl.message(
      'Connection',
      name: 'preferencesPageConnectionLbl',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get preferencesPageAppearanceLbl {
    return Intl.message(
      'Appearance',
      name: 'preferencesPageAppearanceLbl',
      desc: '',
      args: [],
    );
  }

  /// `User Interface`
  String get preferencesPageUiLbl {
    return Intl.message(
      'User Interface',
      name: 'preferencesPageUiLbl',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get preferencesPageThemeLbl {
    return Intl.message(
      'Theme',
      name: 'preferencesPageThemeLbl',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get preferencesPageLanguageLbl {
    return Intl.message(
      'Language',
      name: 'preferencesPageLanguageLbl',
      desc: '',
      args: [],
    );
  }

  /// `Translate server names`
  String get preferencesPageTranslateServerNamesLbl {
    return Intl.message(
      'Translate server names',
      name: 'preferencesPageTranslateServerNamesLbl',
      desc: '',
      args: [],
    );
  }

  /// `Hide file extension`
  String get preferencesPageHideFileExtensionLbl {
    return Intl.message(
      'Hide file extension',
      name: 'preferencesPageHideFileExtensionLbl',
      desc: '',
      args: [],
    );
  }

  /// `Show all media categories`
  String get preferencesPageShowAllMediaCategoriesLbl {
    return Intl.message(
      'Show all media categories',
      name: 'preferencesPageShowAllMediaCategoriesLbl',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get preferencesPageSaveBtn {
    return Intl.message(
      'Save',
      name: 'preferencesPageSaveBtn',
      desc: '',
      args: [],
    );
  }

  /// `Loading preferences failed.`
  String get preferencesPageLoadError {
    return Intl.message(
      'Loading preferences failed.',
      name: 'preferencesPageLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Saving preferences failed.`
  String get preferencesPageSaveError {
    return Intl.message(
      'Saving preferences failed.',
      name: 'preferencesPageSaveError',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to Mopidy server failed.`
  String get preferencesPageConnectErrorTitle {
    return Intl.message(
      'Connecting to Mopidy server failed.',
      name: 'preferencesPageConnectErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Max retries exceeded.`
  String get preferencesPageConnectErrorDetails {
    return Intl.message(
      'Max retries exceeded.',
      name: 'preferencesPageConnectErrorDetails',
      desc: '',
      args: [],
    );
  }

  /// `Browse`
  String get libraryBrowserPageTitle {
    return Intl.message(
      'Browse',
      name: 'libraryBrowserPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Playlists`
  String get libraryPlaylistSeparator {
    return Intl.message(
      'Playlists',
      name: 'libraryPlaylistSeparator',
      desc: '',
      args: [],
    );
  }

  /// `Tracks`
  String get trackListPageTitle {
    return Intl.message(
      'Tracks',
      name: 'trackListPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Playlist`
  String get playlistPageTitle {
    return Intl.message(
      'Playlist',
      name: 'playlistPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get searchPageTitle {
    return Intl.message(
      'Search',
      name: 'searchPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search not supported, because Mopidy-Local server extension is not enabled.`
  String get searchPageNotSupportedMessage {
    return Intl.message(
      'Search not supported, because Mopidy-Local server extension is not enabled.',
      name: 'searchPageNotSupportedMessage',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get aboutPageTitle {
    return Intl.message(
      'About',
      name: 'aboutPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `A https://mopidy.com[Mopidy] client implemented with Flutter and Dart.\nThe https://github.com/nerk/mopicon[source code] is available on Github.`
  String get aboutPageDescription {
    return Intl.message(
      'A https://mopidy.com[Mopidy] client implemented with Flutter and Dart.\nThe https://github.com/nerk/mopicon[source code] is available on Github.',
      name: 'aboutPageDescription',
      desc: '',
      args: [],
    );
  }

  /// `License`
  String get aboutPageLicenseSection {
    return Intl.message(
      'License',
      name: 'aboutPageLicenseSection',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get aboutPageVersionSection {
    return Intl.message(
      'Version',
      name: 'aboutPageVersionSection',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get aboutPageHelpSection {
    return Intl.message(
      'Help',
      name: 'aboutPageHelpSection',
      desc: '',
      args: [],
    );
  }

  /// `https://github.com/nerk/mopicon[Documentation and Help]`
  String get aboutPageHelpDescription {
    return Intl.message(
      'https://github.com/nerk/mopicon[Documentation and Help]',
      name: 'aboutPageHelpDescription',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch '{url}'.`
  String aboutPageLinkLaunchError(String url) {
    return Intl.message(
      'Could not launch \'$url\'.',
      name: 'aboutPageLinkLaunchError',
      desc: '',
      args: [url],
    );
  }

  /// `Select Playlist`
  String get selectPlaylistDialogTitle {
    return Intl.message(
      'Select Playlist',
      name: 'selectPlaylistDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `New Playlist`
  String get newPlaylistDialogTitle {
    return Intl.message(
      'New Playlist',
      name: 'newPlaylistDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get newPlaylistDialogNameLabel {
    return Intl.message(
      'Name',
      name: 'newPlaylistDialogNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter name of new playlist`
  String get newPlaylistDialogNameHint {
    return Intl.message(
      'Enter name of new playlist',
      name: 'newPlaylistDialogNameHint',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get newPlaylistDialogSubmitBtn {
    return Intl.message(
      'OK',
      name: 'newPlaylistDialogSubmitBtn',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get newPlaylistDialogCancelBtn {
    return Intl.message(
      'Cancel',
      name: 'newPlaylistDialogCancelBtn',
      desc: '',
      args: [],
    );
  }

  /// `Could not create playlist.`
  String get newPlaylistCreateError {
    return Intl.message(
      'Could not create playlist.',
      name: 'newPlaylistCreateError',
      desc: '',
      args: [],
    );
  }

  /// `Rename Playlist`
  String get renamePlaylistDialogTitle {
    return Intl.message(
      'Rename Playlist',
      name: 'renamePlaylistDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get renamePlaylistDialogNameLabel {
    return Intl.message(
      'Name',
      name: 'renamePlaylistDialogNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter playlist new name`
  String get renamePlaylistDialogNameHint {
    return Intl.message(
      'Enter playlist new name',
      name: 'renamePlaylistDialogNameHint',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get renamePlaylistDialogSubmitBtn {
    return Intl.message(
      'OK',
      name: 'renamePlaylistDialogSubmitBtn',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get renamePlaylistDialogCancelBtn {
    return Intl.message(
      'Cancel',
      name: 'renamePlaylistDialogCancelBtn',
      desc: '',
      args: [],
    );
  }

  /// `Could not rename playlist.`
  String get renamePlaylistCreateError {
    return Intl.message(
      'Could not rename playlist.',
      name: 'renamePlaylistCreateError',
      desc: '',
      args: [],
    );
  }

  /// `Playlist already exists.`
  String get playlistAlreadyExistsError {
    return Intl.message(
      'Playlist already exists.',
      name: 'playlistAlreadyExistsError',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid playlist name.`
  String get playlistNameInvalidError {
    return Intl.message(
      'Please enter a valid playlist name.',
      name: 'playlistNameInvalidError',
      desc: '',
      args: [],
    );
  }

  /// `Delete Playlist`
  String get deletePlaylistDialogTitle {
    return Intl.message(
      'Delete Playlist',
      name: 'deletePlaylistDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete playlist '{name}'?`
  String deletePlaylistDialogMessage(String name) {
    return Intl.message(
      'Do you really want to delete playlist \'$name\'?',
      name: 'deletePlaylistDialogMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Playlist could not be deleted.`
  String get deletePlaylistError {
    return Intl.message(
      'Playlist could not be deleted.',
      name: 'deletePlaylistError',
      desc: '',
      args: [],
    );
  }

  /// `Add new stream to Playlist`
  String get newPlaylistStreamDialogTitle {
    return Intl.message(
      'Add new stream to Playlist',
      name: 'newPlaylistStreamDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add new stream to Tracklist`
  String get newTracklistStreamDialogTitle {
    return Intl.message(
      'Add new stream to Tracklist',
      name: 'newTracklistStreamDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `URI`
  String get newStreamDialogUriLabel {
    return Intl.message(
      'URI',
      name: 'newStreamDialogUriLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter URI of new stream`
  String get newStreamDialogUriHint {
    return Intl.message(
      'Enter URI of new stream',
      name: 'newStreamDialogUriHint',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get newStreamDialogSubmitBtn {
    return Intl.message(
      'OK',
      name: 'newStreamDialogSubmitBtn',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get newStreamDialogCancelBtn {
    return Intl.message(
      'Cancel',
      name: 'newStreamDialogCancelBtn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid URI for the stream.`
  String get newStreamUriInvalid {
    return Intl.message(
      'Please enter a valid URI for the stream.',
      name: 'newStreamUriInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Could not create stream.`
  String get newStreamCreateError {
    return Intl.message(
      'Could not create stream.',
      name: 'newStreamCreateError',
      desc: '',
      args: [],
    );
  }

  /// `Stream cannot be accessed. Invalid URI?`
  String get newStreamAccessError {
    return Intl.message(
      'Stream cannot be accessed. Invalid URI?',
      name: 'newStreamAccessError',
      desc: '',
      args: [],
    );
  }

  /// `Add to TrackList`
  String get menuAddToTracklist {
    return Intl.message(
      'Add to TrackList',
      name: 'menuAddToTracklist',
      desc: '',
      args: [],
    );
  }

  /// `Add to Playlist`
  String get menuAddToPlaylist {
    return Intl.message(
      'Add to Playlist',
      name: 'menuAddToPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get menuSettings {
    return Intl.message(
      'Settings',
      name: 'menuSettings',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get menuAbout {
    return Intl.message(
      'About',
      name: 'menuAbout',
      desc: '',
      args: [],
    );
  }

  /// `Create Playlist`
  String get menuNewPlaylist {
    return Intl.message(
      'Create Playlist',
      name: 'menuNewPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `Rename Playlist`
  String get menuRenamePlaylist {
    return Intl.message(
      'Rename Playlist',
      name: 'menuRenamePlaylist',
      desc: '',
      args: [],
    );
  }

  /// `New Stream`
  String get menuNewStream {
    return Intl.message(
      'New Stream',
      name: 'menuNewStream',
      desc: '',
      args: [],
    );
  }

  /// `Play now`
  String get menuPlayNow {
    return Intl.message(
      'Play now',
      name: 'menuPlayNow',
      desc: '',
      args: [],
    );
  }

  /// `Selection`
  String get menuSelection {
    return Intl.message(
      'Selection',
      name: 'menuSelection',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get menuSelectAll {
    return Intl.message(
      'Select all',
      name: 'menuSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get menuRefresh {
    return Intl.message(
      'Refresh',
      name: 'menuRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Remove selected`
  String get menuRemoveSelected {
    return Intl.message(
      'Remove selected',
      name: 'menuRemoveSelected',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get menuRemove {
    return Intl.message(
      'Remove',
      name: 'menuRemove',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get menuDelete {
    return Intl.message(
      'Delete',
      name: 'menuDelete',
      desc: '',
      args: [],
    );
  }

  /// `Clear list`
  String get menuClearList {
    return Intl.message(
      'Clear list',
      name: 'menuClearList',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get nameTranslateFiles {
    return Intl.message(
      'Files',
      name: 'nameTranslateFiles',
      desc: '',
      args: [],
    );
  }

  /// `Local Media`
  String get nameTranslateLocalMedia {
    return Intl.message(
      'Local Media',
      name: 'nameTranslateLocalMedia',
      desc: '',
      args: [],
    );
  }

  /// `Albums`
  String get nameTranslateAlbums {
    return Intl.message(
      'Albums',
      name: 'nameTranslateAlbums',
      desc: '',
      args: [],
    );
  }

  /// `Artists`
  String get nameTranslateArtists {
    return Intl.message(
      'Artists',
      name: 'nameTranslateArtists',
      desc: '',
      args: [],
    );
  }

  /// `Performers`
  String get nameTranslatePerformers {
    return Intl.message(
      'Performers',
      name: 'nameTranslatePerformers',
      desc: '',
      args: [],
    );
  }

  /// `Composers`
  String get nameTranslateComposers {
    return Intl.message(
      'Composers',
      name: 'nameTranslateComposers',
      desc: '',
      args: [],
    );
  }

  /// `Genres`
  String get nameTranslateGenres {
    return Intl.message(
      'Genres',
      name: 'nameTranslateGenres',
      desc: '',
      args: [],
    );
  }

  /// `Tracks`
  String get nameTranslateTracks {
    return Intl.message(
      'Tracks',
      name: 'nameTranslateTracks',
      desc: '',
      args: [],
    );
  }

  /// `Release Years`
  String get nameTranslateReleaseYears {
    return Intl.message(
      'Release Years',
      name: 'nameTranslateReleaseYears',
      desc: '',
      args: [],
    );
  }

  /// `Last Week's Updates`
  String get nameTranslateLastWeeksUpdates {
    return Intl.message(
      'Last Week\'s Updates',
      name: 'nameTranslateLastWeeksUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Last Month's Updates`
  String get nameTranslateLastMonthsUpdates {
    return Intl.message(
      'Last Month\'s Updates',
      name: 'nameTranslateLastMonthsUpdates',
      desc: '',
      args: [],
    );
  }

  /// `{n} tracks added to tracklist.`
  String tracksAddedToTracklistMessage(int n) {
    return Intl.message(
      '$n tracks added to tracklist.',
      name: 'tracksAddedToTracklistMessage',
      desc: '',
      args: [n],
    );
  }

  /// `Track added to tracklist.`
  String get trackAddedToTracklistMessage {
    return Intl.message(
      'Track added to tracklist.',
      name: 'trackAddedToTracklistMessage',
      desc: '',
      args: [],
    );
  }

  /// `{n} tracks added to playlist {p}.`
  String tracksAddedToPlaylistMessage(int n, String p) {
    return Intl.message(
      '$n tracks added to playlist $p.',
      name: 'tracksAddedToPlaylistMessage',
      desc: '',
      args: [n, p],
    );
  }

  /// `Track added to playlist {p}.`
  String trackAddedToPlaylistMessage(String p) {
    return Intl.message(
      'Track added to playlist $p.',
      name: 'trackAddedToPlaylistMessage',
      desc: '',
      args: [p],
    );
  }

  /// `Year: {date}`
  String albumDateLbl(Object date) {
    return Intl.message(
      'Year: $date',
      name: 'albumDateLbl',
      desc: '',
      args: [date],
    );
  }

  /// `Tracks: {numTracks}`
  String albumNumTracksLbl(Object numTracks) {
    return Intl.message(
      'Tracks: $numTracks',
      name: 'albumNumTracksLbl',
      desc: '',
      args: [numTracks],
    );
  }

  /// `Disc: {discNo}`
  String nowPlayingDiscLbl(int discNo) {
    return Intl.message(
      'Disc: $discNo',
      name: 'nowPlayingDiscLbl',
      desc: '',
      args: [discNo],
    );
  }

  /// `Track: {trackNo}`
  String nowPlayingTrackNoLbl(int trackNo) {
    return Intl.message(
      'Track: $trackNo',
      name: 'nowPlayingTrackNoLbl',
      desc: '',
      args: [trackNo],
    );
  }

  /// `Year: {date}`
  String nowPlayingDateLbl(Object date) {
    return Intl.message(
      'Year: $date',
      name: 'nowPlayingDateLbl',
      desc: '',
      args: [date],
    );
  }

  /// `Bitrate: {bitrate} kbit/s`
  String nowPlayingBitrateLbl(Object bitrate) {
    return Intl.message(
      'Bitrate: $bitrate kbit/s',
      name: 'nowPlayingBitrateLbl',
      desc: '',
      args: [bitrate],
    );
  }

  /// `Logging`
  String get loggingLbl {
    return Intl.message(
      'Logging',
      name: 'loggingLbl',
      desc: '',
      args: [],
    );
  }

  /// `Log`
  String get logDialogTitle {
    return Intl.message(
      'Log',
      name: 'logDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show Log`
  String get showLogButtonLbl {
    return Intl.message(
      'Show Log',
      name: 'showLogButtonLbl',
      desc: '',
      args: [],
    );
  }

  /// `Clear Log`
  String get clearLogButtonLbl {
    return Intl.message(
      'Clear Log',
      name: 'clearLogButtonLbl',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
