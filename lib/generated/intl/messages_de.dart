// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(url) => "Link \'${url}\' konnte nicht geöffnet werden.";

  static String m1(date) => "Jahr: ${date}";

  static String m2(numTracks) => "Tracks: ${numTracks}";

  static String m3(name) => "Playlist \'${name}\' unwiderruflich löschen?";

  static String m4(bitrate) => "Bitrate: ${bitrate} kbit/s";

  static String m5(date) => "Jahr: ${date}";

  static String m6(discNo) => "CD: ${discNo}";

  static String m7(trackNo) => "Titel Nr.: ${trackNo}";

  static String m8(p) => "Titel zu Playlist \'${p}\' hinzugefügt.";

  static String m9(n, p) => "${n} Titel zu Playlist \'${p}\' hinzugefügt.";

  static String m10(n) => "${n} Titel zu Wiedergabeliste hinzugefügt.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abortBtn": MessageLookupByLibrary.simpleMessage("Abbruch"),
        "aboutPageDescription": MessageLookupByLibrary.simpleMessage(
            "Ein https://mopidy.com[Mopidy-Client] implementiert mit Flutter und Dart.\nDer http://github.com/nerk/mopicon[Sourcecode] ist auf Github verfügbar."),
        "aboutPageHelpDescription": MessageLookupByLibrary.simpleMessage(
            "https://github.com/nerk/mopicon[Dokumentation und Hilfe]"),
        "aboutPageHelpSection": MessageLookupByLibrary.simpleMessage("Hilfe"),
        "aboutPageLicenseSection":
            MessageLookupByLibrary.simpleMessage("Lizenz"),
        "aboutPageLinkLaunchError": m0,
        "aboutPageTitle": MessageLookupByLibrary.simpleMessage("Über"),
        "aboutPageVersionSection":
            MessageLookupByLibrary.simpleMessage("Version"),
        "albumDateLbl": m1,
        "albumNumTracksLbl": m2,
        "appName": MessageLookupByLibrary.simpleMessage("Mopicon"),
        "cancelBtn": MessageLookupByLibrary.simpleMessage("Abbruch"),
        "clearLogButtonLbl":
            MessageLookupByLibrary.simpleMessage("Log löschen"),
        "connectingPageConnecting":
            MessageLookupByLibrary.simpleMessage("Verbinden..."),
        "connectingPageStopBtn": MessageLookupByLibrary.simpleMessage("Stopp"),
        "deletePlaylistDialogMessage": m3,
        "deletePlaylistDialogTitle":
            MessageLookupByLibrary.simpleMessage("Playlist löschen"),
        "deletePlaylistError": MessageLookupByLibrary.simpleMessage(
            "Playlist konnte nicht gelöscht werden."),
        "homePageBrowseLbl": MessageLookupByLibrary.simpleMessage("Bibliothek"),
        "homePageSearchLbl": MessageLookupByLibrary.simpleMessage("Suche"),
        "homePageTracksLbl": MessageLookupByLibrary.simpleMessage("Wiedergabe"),
        "libraryBrowserPageTitle":
            MessageLookupByLibrary.simpleMessage("Bibliothek"),
        "libraryPlaylistSeparator":
            MessageLookupByLibrary.simpleMessage("Playlists"),
        "logDialogTitle": MessageLookupByLibrary.simpleMessage("Log"),
        "loggingLbl": MessageLookupByLibrary.simpleMessage("Logging"),
        "menuAbout": MessageLookupByLibrary.simpleMessage("Über"),
        "menuAddToPlaylist":
            MessageLookupByLibrary.simpleMessage("Zu Playlist hinzufügen"),
        "menuAddToTracklist": MessageLookupByLibrary.simpleMessage(
            "Zu Wiedergabeliste hinzufügen"),
        "menuClearList": MessageLookupByLibrary.simpleMessage("Liste leeren"),
        "menuDelete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "menuNewPlaylist":
            MessageLookupByLibrary.simpleMessage("Neue Playlist"),
        "menuNewStream": MessageLookupByLibrary.simpleMessage("Neuer Stream"),
        "menuPlayNow": MessageLookupByLibrary.simpleMessage("Abspielen"),
        "menuRefresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "menuRemove": MessageLookupByLibrary.simpleMessage("Entfernen"),
        "menuRemoveSelected":
            MessageLookupByLibrary.simpleMessage("Selektierte entfernen"),
        "menuRenamePlaylist":
            MessageLookupByLibrary.simpleMessage("Playlist umbenennen"),
        "menuSelectAll":
            MessageLookupByLibrary.simpleMessage("Alles auswählen"),
        "menuSelection": MessageLookupByLibrary.simpleMessage("Auswahl"),
        "menuSettings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "nameTranslateAlbums": MessageLookupByLibrary.simpleMessage("Alben"),
        "nameTranslateArtists":
            MessageLookupByLibrary.simpleMessage("Künstler"),
        "nameTranslateComposers":
            MessageLookupByLibrary.simpleMessage("Komponisten"),
        "nameTranslateFiles": MessageLookupByLibrary.simpleMessage("Dateien"),
        "nameTranslateGenres": MessageLookupByLibrary.simpleMessage("Genres"),
        "nameTranslateLastMonthsUpdates":
            MessageLookupByLibrary.simpleMessage("Letzten Monat aktualisiert"),
        "nameTranslateLastWeeksUpdates":
            MessageLookupByLibrary.simpleMessage("Letzte Woche aktualisiert"),
        "nameTranslateLocalMedia":
            MessageLookupByLibrary.simpleMessage("Lokale Medien"),
        "nameTranslatePerformers":
            MessageLookupByLibrary.simpleMessage("Interpreten"),
        "nameTranslateReleaseYears":
            MessageLookupByLibrary.simpleMessage("Erscheinungsjahre"),
        "nameTranslateTracks": MessageLookupByLibrary.simpleMessage("Titel"),
        "newPlaylistCreateError": MessageLookupByLibrary.simpleMessage(
            "Playlist konnte nicht angelegt werden."),
        "newPlaylistDialogCancelBtn":
            MessageLookupByLibrary.simpleMessage("Abbruch"),
        "newPlaylistDialogNameHint":
            MessageLookupByLibrary.simpleMessage("Name der Playlist"),
        "newPlaylistDialogNameLabel":
            MessageLookupByLibrary.simpleMessage("Name"),
        "newPlaylistDialogSubmitBtn":
            MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "newPlaylistDialogTitle":
            MessageLookupByLibrary.simpleMessage("Neue Playlist"),
        "newPlaylistStreamDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Neuen Stream zur Playlist hinzufügen"),
        "newStreamAccessError": MessageLookupByLibrary.simpleMessage(
            "Zugriff auf den Stream gescheitert. Ungültiger URI?"),
        "newStreamCreateError": MessageLookupByLibrary.simpleMessage(
            "Stream konnte nicht angelegt werden."),
        "newStreamDialogCancelBtn":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "newStreamDialogSubmitBtn": MessageLookupByLibrary.simpleMessage("OK"),
        "newStreamDialogUriHint":
            MessageLookupByLibrary.simpleMessage("URI des Streams."),
        "newStreamDialogUriLabel": MessageLookupByLibrary.simpleMessage("URI"),
        "newStreamUriInvalid": MessageLookupByLibrary.simpleMessage(
            "Bitte gültigen URI des Streams eingeben."),
        "newTracklistStreamDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Neuen Stream zur Wiedergabeliste hinzufügen"),
        "noBtn": MessageLookupByLibrary.simpleMessage("Nein"),
        "nowPlayingBitrateLbl": m4,
        "nowPlayingDateLbl": m5,
        "nowPlayingDiscLbl": m6,
        "nowPlayingTrackNoLbl": m7,
        "okBtn": MessageLookupByLibrary.simpleMessage("OK"),
        "pageNotFoundMsg":
            MessageLookupByLibrary.simpleMessage("Seite nicht gefunden!"),
        "playlistAlreadyExistsError": MessageLookupByLibrary.simpleMessage(
            "Playlist mit diesem Namen existiert bereits."),
        "playlistNameInvalidError": MessageLookupByLibrary.simpleMessage(
            "Bitte gültigen Namen eingeben."),
        "playlistPageTitle": MessageLookupByLibrary.simpleMessage("Playlist"),
        "preferencesPageAppearanceLbl":
            MessageLookupByLibrary.simpleMessage("Erscheinungsbild"),
        "preferencesPageConnectErrorDetails":
            MessageLookupByLibrary.simpleMessage(
                "Maximale Versuche überschritten."),
        "preferencesPageConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage(
                "Keine Verbindung zum Mopidy Server."),
        "preferencesPageConnectionLbl":
            MessageLookupByLibrary.simpleMessage("Verbindung"),
        "preferencesPageHideFileExtensionLbl":
            MessageLookupByLibrary.simpleMessage(
                "Mopidy File-Extension verbergen"),
        "preferencesPageLanguageLbl":
            MessageLookupByLibrary.simpleMessage("Sprache"),
        "preferencesPageLoadError": MessageLookupByLibrary.simpleMessage(
            "Einstellungen konnten nicht geladen werden."),
        "preferencesPageMopidyPortHintText":
            MessageLookupByLibrary.simpleMessage("Port des Mopidy-Servers."),
        "preferencesPageMopidyPortInvalid":
            MessageLookupByLibrary.simpleMessage(
                "Bitte gültigen Port eingeben."),
        "preferencesPageMopidyPortLblText":
            MessageLookupByLibrary.simpleMessage("Mopidy-Server Port *"),
        "preferencesPageMopidyServerHintText":
            MessageLookupByLibrary.simpleMessage(
                "IP-Adresse oder Name des Mopidy-Servers."),
        "preferencesPageMopidyServerInvalid":
            MessageLookupByLibrary.simpleMessage(
                "Bitte gültigen Namen oder IP-Adresse eingeben."),
        "preferencesPageMopidyServerLblText":
            MessageLookupByLibrary.simpleMessage("Mopidy Server *"),
        "preferencesPageSaveBtn":
            MessageLookupByLibrary.simpleMessage("Speichern"),
        "preferencesPageSaveError": MessageLookupByLibrary.simpleMessage(
            "Einstellungen konnten nicht gespeichert werden."),
        "preferencesPageShowAllMediaCategoriesLbl":
            MessageLookupByLibrary.simpleMessage(
                "Alle Medienkategorien anzeigen"),
        "preferencesPageThemeLbl":
            MessageLookupByLibrary.simpleMessage("Theme"),
        "preferencesPageTitle":
            MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "preferencesPageTranslateServerNamesLbl":
            MessageLookupByLibrary.simpleMessage("Server-Namen übersetzen"),
        "preferencesPageUiLbl":
            MessageLookupByLibrary.simpleMessage("User Interface"),
        "renamePlaylistCreateError": MessageLookupByLibrary.simpleMessage(
            "Playlist konnte nicht umbenannt werden."),
        "renamePlaylistDialogCancelBtn":
            MessageLookupByLibrary.simpleMessage("Abbruch"),
        "renamePlaylistDialogNameHint":
            MessageLookupByLibrary.simpleMessage("Neuer Name der Playlist"),
        "renamePlaylistDialogNameLabel":
            MessageLookupByLibrary.simpleMessage("Name"),
        "renamePlaylistDialogSubmitBtn":
            MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "renamePlaylistDialogTitle":
            MessageLookupByLibrary.simpleMessage("Playlist umbenennen"),
        "retryBtn": MessageLookupByLibrary.simpleMessage("Wiederholen"),
        "saveBtn": MessageLookupByLibrary.simpleMessage("Speichern"),
        "searchPageNotSupportedMessage": MessageLookupByLibrary.simpleMessage(
            "Suche wird nicht unterstützt, weil die Mopidy-Local Erweiterung des Servers nicht aktiviert ist."),
        "searchPageTitle": MessageLookupByLibrary.simpleMessage("Suche"),
        "selectPlaylistDialogTitle":
            MessageLookupByLibrary.simpleMessage("Playlist auswählen"),
        "showLogButtonLbl":
            MessageLookupByLibrary.simpleMessage("Log anzeigen"),
        "submitBtn": MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "trackAddedToPlaylistMessage": m8,
        "trackAddedToTracklistMessage": MessageLookupByLibrary.simpleMessage(
            "Titel zu Wiedergabeliste hinzugefügt."),
        "trackListPageTitle":
            MessageLookupByLibrary.simpleMessage("Wiedergabeliste"),
        "tracksAddedToPlaylistMessage": m9,
        "tracksAddedToTracklistMessage": m10,
        "yesBtn": MessageLookupByLibrary.simpleMessage("Ja")
      };
}
