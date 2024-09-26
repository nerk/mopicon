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
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/components/titled_divider.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:mopicon/common/globals.dart';
import 'package:mopicon/utils/logging_utils.dart' as lg;
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/components/show_text_dialog.dart';
import 'preferences_controller.dart';
import 'package:mopicon/services/mopidy_service.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesState();
}

class _PreferencesState extends State<PreferencesPage> {
  final preferences = GetIt.instance<PreferencesController>();
  final mopidyService = GetIt.instance<MopidyService>();
  final preferencesFormKey =
      GlobalKey<FormState>(debugLabel: "preferencesPage");

  AppLocale? newLocale;
  String? originalUri;

  Future<void> load() async {
    await preferences.load();
    setState(() {
      originalUri = preferences.url;
    });
    return Future.value(null);
  }

  Future<void> save() async {
    if (preferencesFormKey.currentState?.validate() ?? false) {
      if (preferences.hasChanged) {
        await preferences.save();
        setState(() {});
      }
    }
    return Future.value(null);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => closeSnackBar());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<AppTheme>> lightThemes =
        <DropdownMenuEntry<AppTheme>>[];
    for (final AppTheme theme in AppThemes.lightThemes) {
      if (!theme.dark) {
        lightThemes.add(
          DropdownMenuEntry<AppTheme>(
              value: theme,
              label: theme.name,
              leadingIcon: Container(
                  width: 20,
                  height: 20,
                  color: theme.data.colorScheme.primaryContainer)),
        );
      }
    }

    final List<DropdownMenuEntry<AppTheme>> darkThemes =
        <DropdownMenuEntry<AppTheme>>[];
    for (final AppTheme theme in AppThemes.darkThemes) {
      if (theme.dark) {
        darkThemes.add(
          DropdownMenuEntry<AppTheme>(
              value: theme,
              label: theme.name,
              leadingIcon: Container(
                  width: 20,
                  height: 20,
                  color: theme.data.colorScheme.primaryContainer)),
        );
      }
    }

    final List<DropdownMenuEntry<AppLocale>> locales =
        <DropdownMenuEntry<AppLocale>>[];
    for (final AppLocale locale in AppLocales().locales) {
      locales.add(
        DropdownMenuEntry<AppLocale>(
            value: locale,
            label: locale.getLabel(preferences.appLocale.locale.languageCode)),
      );
    }

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                try {
                  await load();
                  S.load(preferences.appLocale.locale);
                  Globals.applicationRoutes.gotoHome();
                } catch (e) {
                  if (context.mounted) {
                    showError(S.of(context).preferencesPageLoadError, null);
                  }
                }
              },
            ),
            title: Text(S.of(context).preferencesPageTitle),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                onPressed: () async {
                  if (preferencesFormKey.currentState?.validate() ?? false) {
                    var preferencesPageSaveError =
                        S.of(context).preferencesPageSaveError;
                    try {
                      preferences.appLocale =
                          newLocale ?? preferences.appLocale;
                      await save();
                      // reconnect if connection changed or not connected at all
                      if (originalUri != preferences.url ||
                          !mopidyService.connected) {
                        mopidyService.stop();
                        GetIt.instance<MopidyService>()
                            .connect(preferences.url);
                      }
                      S.load(preferences.appLocale.locale);
                      Globals.applicationRoutes.gotoHome();
                    } catch (e) {
                      showError(preferencesPageSaveError, null);
                    }
                  }
                },
                child: Text(S.of(context).preferencesPageSaveBtn),
              )
            ]),
        body: MaterialPageFrame(
            child: SingleChildScrollView(
                child: Form(
                    key: preferencesFormKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TitledDivider(
                              S.of(context).preferencesPageConnectionLbl),
                          TextFormField(
                            initialValue: preferences.host,
                            autocorrect: false,
                            decoration: InputDecoration(
                                icon: const Icon(Icons.lan),
                                hintText: S
                                    .of(context)
                                    .preferencesPageMopidyServerHintText,
                                labelText: S
                                    .of(context)
                                    .preferencesPageMopidyServerLblText),
                            autofillHints: [preferences.host ?? ''],
                            onSaved: (String? value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            onTapOutside: (PointerDownEvent ev) {
                              //preferences.save();
                            },
                            onChanged: (String value) {
                              preferences.host = value;
                            },
                            validator: (String? value) {
                              return value != null && value.isNotEmpty
                                  ? null
                                  : S
                                      .of(context)
                                      .preferencesPageMopidyServerInvalid;
                            },
                          ),
                          const VerticalSpacer(),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: preferences.port != null
                                ? preferences.port.toString()
                                : '',
                            autocorrect: false,
                            decoration: InputDecoration(
                                icon: const Icon(Icons.input_rounded),
                                hintText: S
                                    .of(context)
                                    .preferencesPageMopidyPortHintText,
                                labelText: S
                                    .of(context)
                                    .preferencesPageMopidyPortLblText),
                            autofillHints: [
                              preferences.port != null
                                  ? preferences.port.toString()
                                  : ''
                            ],
                            onSaved: (String? value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            onTapOutside: (PointerDownEvent ev) {
                              //preferences.save();
                            },
                            onChanged: (String value) {
                              preferences.port =
                                  (value.isNotEmpty ? int.parse(value) : null);
                            },
                            validator: (String? value) {
                              return value != null && value.isNotEmpty
                                  ? null
                                  : S
                                      .of(context)
                                      .preferencesPageMopidyPortInvalid;
                            },
                            maxLength: 5,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          TitledDivider(
                              S.of(context).preferencesPageAppearanceLbl),
                          Row(mainAxisSize: MainAxisSize.max, children: [
                            Text(S.of(context).preferencesPageThemeDark),
                            const SizedBox(width: 10),
                            Switch(
                              value: preferences.dark,
                              onChanged: (bool value) {
                                setState(() {
                                  preferences.dark = value;
                                  preferences.theme = AppThemes.get(
                                      preferences.theme.name, value);
                                });
                              },
                            ),
                            Expanded(
                                child: DropdownMenu<AppTheme>(
                              expandedInsets: const EdgeInsets.only(left: 30),
                              requestFocusOnTap: false,
                              initialSelection: preferences.theme,
                              label:
                                  Text(S.of(context).preferencesPageThemeLbl),
                              leadingIcon: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 20,
                                  height: 20,
                                  color: preferences
                                      .theme.data.colorScheme.primaryContainer),
                              dropdownMenuEntries:
                                  preferences.dark ? darkThemes : lightThemes,
                              onSelected: (AppTheme? theme) {
                                if (theme != null) {
                                  setState(() {
                                    preferences.theme = theme;
                                  });
                                }
                              },
                            ))
                          ]),
                          const SizedBox(height: 20),
                          DropdownMenu<AppLocale>(
                            expandedInsets: EdgeInsets.zero,
                            requestFocusOnTap: false,
                            initialSelection: preferences.appLocale,
                            controller: null,
                            label:
                                Text(S.of(context).preferencesPageLanguageLbl),
                            dropdownMenuEntries: locales,
                            onSelected: (AppLocale? locale) {
                              if (locale != null) {
                                setState(() {
                                  newLocale = locale;
                                  preferences.appLocale = newLocale!;
                                });
                              }
                            },
                          ),
                          TitledDivider(S.of(context).preferencesPageUiLbl),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(S
                                .of(context)
                                .preferencesPageHideFileExtensionLbl),
                            value: preferences.hideFileExtension,
                            onChanged: (bool? value) {
                              setState(() {
                                preferences.hideFileExtension = value!;
                              });
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(S
                                .of(context)
                                .preferencesPageTranslateServerNamesLbl),
                            value: preferences.translateServerNames,
                            onChanged: (bool? value) {
                              setState(() {
                                preferences.translateServerNames = value!;
                              });
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(S
                                .of(context)
                                .preferencesPageShowAllMediaCategoriesLbl),
                            value: preferences.showAllMediaCategories,
                            onChanged: (bool? value) {
                              setState(() {
                                preferences.showAllMediaCategories = value!;
                              });
                            },
                          ),
                          TitledDivider(S.of(context).loggingLbl),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            trailing: ElevatedButton(
                                child: Text(S.of(context).showLogButtonLbl),
                                onPressed: () {
                                  showTextDialog(
                                      context,
                                      S.of(context).logDialogTitle,
                                      lg.getLogMessages());
                                }),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            trailing: ElevatedButton(
                                child: Text(S.of(context).clearLogButtonLbl),
                                onPressed: () {
                                  lg.clearLogMessages();
                                }),
                          ),
                        ])))));
  }
}
