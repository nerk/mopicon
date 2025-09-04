// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(date) => "Year: ${date}";

  static String m1(numTracks) => "Tracks: ${numTracks}";

  static String m2(p) => "Could not add tracks to Playlist \'${p}\'.";

  static String m3(name) =>
      "Do you really want to delete playlist \'${name}\'?";

  static String m4(bitrate) => "Bitrate: ${bitrate} kbit/s";

  static String m5(date) => "Year: ${date}";

  static String m6(discNo) => "Disc: ${discNo}";

  static String m7(trackNo) => "Track: ${trackNo}";

  static String m8(p) => "Track added to playlist ${p}.";

  static String m9(n, p) => "${n} tracks added to playlist ${p}.";

  static String m10(n) => "${n} tracks added to tracklist.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "abortBtn": MessageLookupByLibrary.simpleMessage("Abort"),
    "aboutPageTitle": MessageLookupByLibrary.simpleMessage("About"),
    "albumDateLbl": m0,
    "albumNumTracksLbl": m1,
    "appName": MessageLookupByLibrary.simpleMessage("Mopicon"),
    "cancelBtn": MessageLookupByLibrary.simpleMessage("Cancel"),
    "clearLogButtonLbl": MessageLookupByLibrary.simpleMessage("Clear Log"),
    "connectingPageConnecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "connectingPageStopBtn": MessageLookupByLibrary.simpleMessage("Abort"),
    "couldNotAddTracksToPlaylistError": m2,
    "couldNotAddTracksToTracklistError": MessageLookupByLibrary.simpleMessage(
      "Could not add tracks to tracklist.",
    ),
    "deletePlaylistDialogMessage": m3,
    "deletePlaylistDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Playlist",
    ),
    "deletePlaylistError": MessageLookupByLibrary.simpleMessage(
      "Playlist could not be deleted.",
    ),
    "homePageBrowseLbl": MessageLookupByLibrary.simpleMessage("Browse"),
    "homePageSearchLbl": MessageLookupByLibrary.simpleMessage("Search"),
    "homePageTracksLbl": MessageLookupByLibrary.simpleMessage("Tracks"),
    "libraryBrowserPageTitle": MessageLookupByLibrary.simpleMessage("Browse"),
    "libraryPlaylistSeparator": MessageLookupByLibrary.simpleMessage(
      "Playlists",
    ),
    "logDialogTitle": MessageLookupByLibrary.simpleMessage("Log"),
    "loggingLbl": MessageLookupByLibrary.simpleMessage("Logging"),
    "menuAbout": MessageLookupByLibrary.simpleMessage("About"),
    "menuAddToPlaylist": MessageLookupByLibrary.simpleMessage(
      "Add to Playlist",
    ),
    "menuAddToTracklist": MessageLookupByLibrary.simpleMessage(
      "Add to TrackList",
    ),
    "menuClearList": MessageLookupByLibrary.simpleMessage("Clear list"),
    "menuDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "menuNewPlaylist": MessageLookupByLibrary.simpleMessage("Create Playlist"),
    "menuNewStream": MessageLookupByLibrary.simpleMessage("New Stream"),
    "menuPlayNow": MessageLookupByLibrary.simpleMessage("Play now"),
    "menuRadioBrowser": MessageLookupByLibrary.simpleMessage("Radio Browser"),
    "menuRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "menuRemove": MessageLookupByLibrary.simpleMessage("Remove"),
    "menuRemoveSelected": MessageLookupByLibrary.simpleMessage(
      "Remove selected",
    ),
    "menuRenamePlaylist": MessageLookupByLibrary.simpleMessage(
      "Rename Playlist",
    ),
    "menuSelectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "menuSelection": MessageLookupByLibrary.simpleMessage("Selection"),
    "menuSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "nameTranslateAlbums": MessageLookupByLibrary.simpleMessage("Albums"),
    "nameTranslateArtists": MessageLookupByLibrary.simpleMessage("Artists"),
    "nameTranslateComposers": MessageLookupByLibrary.simpleMessage("Composers"),
    "nameTranslateFiles": MessageLookupByLibrary.simpleMessage("Files"),
    "nameTranslateGenres": MessageLookupByLibrary.simpleMessage("Genres"),
    "nameTranslateLastMonthsUpdates": MessageLookupByLibrary.simpleMessage(
      "Last Month\'s Updates",
    ),
    "nameTranslateLastWeeksUpdates": MessageLookupByLibrary.simpleMessage(
      "Last Week\'s Updates",
    ),
    "nameTranslateLocalMedia": MessageLookupByLibrary.simpleMessage(
      "Local Media",
    ),
    "nameTranslatePerformers": MessageLookupByLibrary.simpleMessage(
      "Performers",
    ),
    "nameTranslateReleaseYears": MessageLookupByLibrary.simpleMessage(
      "Release Years",
    ),
    "nameTranslateTracks": MessageLookupByLibrary.simpleMessage("Tracks"),
    "newPlaylistCreateError": MessageLookupByLibrary.simpleMessage(
      "Could not create playlist.",
    ),
    "newPlaylistDialogCancelBtn": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "newPlaylistDialogNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter name of new playlist",
    ),
    "newPlaylistDialogNameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "newPlaylistDialogSubmitBtn": MessageLookupByLibrary.simpleMessage("OK"),
    "newPlaylistDialogTitle": MessageLookupByLibrary.simpleMessage(
      "New Playlist",
    ),
    "newPlaylistStreamDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Add new stream to Playlist",
    ),
    "newStreamAccessError": MessageLookupByLibrary.simpleMessage(
      "Stream cannot be accessed. Invalid URI?",
    ),
    "newStreamCreateError": MessageLookupByLibrary.simpleMessage(
      "Could not create stream.",
    ),
    "newStreamDialogCancelBtn": MessageLookupByLibrary.simpleMessage("Cancel"),
    "newStreamDialogNameHint": MessageLookupByLibrary.simpleMessage(
      "Name of the stream.",
    ),
    "newStreamDialogNameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "newStreamDialogSubmitBtn": MessageLookupByLibrary.simpleMessage("OK"),
    "newStreamDialogUriHint": MessageLookupByLibrary.simpleMessage(
      "Enter URI of new stream",
    ),
    "newStreamDialogUriLabel": MessageLookupByLibrary.simpleMessage("URI"),
    "newStreamNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Please a name for the stream.",
    ),
    "newStreamUriInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid URI for the stream.",
    ),
    "newTracklistStreamDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Add new stream to Tracklist",
    ),
    "noAlbumInformationError": MessageLookupByLibrary.simpleMessage(
      "No album found for this title.",
    ),
    "noBtn": MessageLookupByLibrary.simpleMessage("No"),
    "nowPlayingBitrateLbl": m4,
    "nowPlayingDateLbl": m5,
    "nowPlayingDiscLbl": m6,
    "nowPlayingTrackNoLbl": m7,
    "okBtn": MessageLookupByLibrary.simpleMessage("OK"),
    "pageNotFoundMsg": MessageLookupByLibrary.simpleMessage("Page not found!"),
    "playlistAlreadyExistsError": MessageLookupByLibrary.simpleMessage(
      "Playlist already exists.",
    ),
    "playlistNameInvalidError": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid playlist name.",
    ),
    "playlistPageTitle": MessageLookupByLibrary.simpleMessage("Playlist"),
    "preferencesPageAppearanceLbl": MessageLookupByLibrary.simpleMessage(
      "Appearance",
    ),
    "preferencesPageConnectErrorDetails": MessageLookupByLibrary.simpleMessage(
      "Max retries exceeded.",
    ),
    "preferencesPageConnectErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Connecting to Mopidy server failed.",
    ),
    "preferencesPageConnectionLbl": MessageLookupByLibrary.simpleMessage(
      "Connection",
    ),
    "preferencesPageHideFileExtensionLbl": MessageLookupByLibrary.simpleMessage(
      "Hide file extension",
    ),
    "preferencesPageLanguageLbl": MessageLookupByLibrary.simpleMessage(
      "Language",
    ),
    "preferencesPageLoadError": MessageLookupByLibrary.simpleMessage(
      "Loading preferences failed.",
    ),
    "preferencesPageMopidyPortHintText": MessageLookupByLibrary.simpleMessage(
      "Port of Mopidy server.",
    ),
    "preferencesPageMopidyPortInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid port number.",
    ),
    "preferencesPageMopidyPortLblText": MessageLookupByLibrary.simpleMessage(
      "Mopidy server port *",
    ),
    "preferencesPageMopidyServerHintText": MessageLookupByLibrary.simpleMessage(
      "IP address or hostname of Mopidy server.",
    ),
    "preferencesPageMopidyServerInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid hostname or IP address.",
    ),
    "preferencesPageMopidyServerLblText": MessageLookupByLibrary.simpleMessage(
      "Mopidy server *",
    ),
    "preferencesPageSaveBtn": MessageLookupByLibrary.simpleMessage("Save"),
    "preferencesPageSaveError": MessageLookupByLibrary.simpleMessage(
      "Saving preferences failed.",
    ),
    "preferencesPageShowAllMediaCategoriesLbl":
        MessageLookupByLibrary.simpleMessage("Show all media categories"),
    "preferencesPageThemeDark": MessageLookupByLibrary.simpleMessage("Dark"),
    "preferencesPageThemeLbl": MessageLookupByLibrary.simpleMessage("Theme"),
    "preferencesPageTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "preferencesPageTranslateServerNamesLbl":
        MessageLookupByLibrary.simpleMessage("Translate server names"),
    "radioBrowserFilterByCountry": MessageLookupByLibrary.simpleMessage(
      "Filter by country...",
    ),
    "radioBrowserLbl": MessageLookupByLibrary.simpleMessage("Radio"),
    "radioBrowserTitle": MessageLookupByLibrary.simpleMessage("RadioBrowser"),
    "renamePlaylistCreateError": MessageLookupByLibrary.simpleMessage(
      "Could not rename playlist.",
    ),
    "renamePlaylistDialogCancelBtn": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "renamePlaylistDialogNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter playlist new name",
    ),
    "renamePlaylistDialogNameLabel": MessageLookupByLibrary.simpleMessage(
      "Name",
    ),
    "renamePlaylistDialogSubmitBtn": MessageLookupByLibrary.simpleMessage("OK"),
    "renamePlaylistDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Rename Playlist",
    ),
    "retryBtn": MessageLookupByLibrary.simpleMessage("Retry"),
    "saveBtn": MessageLookupByLibrary.simpleMessage("Save"),
    "searchPageNotSupportedMessage": MessageLookupByLibrary.simpleMessage(
      "Search not supported, because Mopidy-Local server extension is not enabled.",
    ),
    "searchPageTitle": MessageLookupByLibrary.simpleMessage("Search"),
    "selectPlaylistDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Select Playlist",
    ),
    "showLogButtonLbl": MessageLookupByLibrary.simpleMessage("Show Log"),
    "submitBtn": MessageLookupByLibrary.simpleMessage("Submit"),
    "trackAddedToPlaylistMessage": m8,
    "trackAddedToTracklistMessage": MessageLookupByLibrary.simpleMessage(
      "Track added to tracklist.",
    ),
    "trackListPageTitle": MessageLookupByLibrary.simpleMessage("Tracks"),
    "tracksAddedToPlaylistMessage": m9,
    "tracksAddedToTracklistMessage": m10,
    "yesBtn": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
