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
import 'package:flutter/foundation.dart';
import 'package:mopicon/common/globals.dart';
import 'package:mopicon/common/selected_item_positions.dart';

typedef MenuCallbackFunction<T> = void Function(BuildContext context, T? arg, int? index);

// Check if menu item is applicable to current item
typedef MenuItemApplicableCallback<T> = bool Function(T? arg, int? index);

typedef MenuBuilderFunction<T> = MenuBuilder Function(BuildContext context, T? arg, int? index);

class MenuItem<T extends Object> {
  final String label;
  final IconData? iconData;
  final MenuCallbackFunction<T>? callback;
  final ValueListenable<T>? valueListenable;
  final MenuItemApplicableCallback<T>? applicable;

  MenuItem(this.label, {this.iconData, this.callback, this.valueListenable, this.applicable});

  bool isApplicable(T? arg, int? index) {
    return applicable == null || applicable!(arg, index);
  }
}

class MenuBuilder<T extends Object> {
  final MenuItemApplicableCallback<T>? applicableCallback;

  var menuItems = List<MenuItem<T>?>.empty(growable: true);

  MenuBuilder({this.applicableCallback});

  MenuBuilder<T> addDivider() {
    menuItems.add(null);
    return this;
  }

  MenuBuilder<T> addMenuItem(String label, IconData? iconData, MenuCallbackFunction<T>? callback,
      {ValueListenable<T>? valueListenable, MenuItemApplicableCallback? applicableCallback}) {
    menuItems.add(MenuItem(label,
        iconData: iconData, callback: callback, valueListenable: valueListenable, applicable: applicableCallback));
    return this;
  }

  MenuBuilder<T> addSettingsMenuItem(String label) {
    void settings(_, __, ___) {
      Globals.applicationRoutes.gotoSettings();
    }

    return addMenuItem(label, Icons.settings, settings);
  }

  MenuBuilder<T> addHelpMenuItem(String label) {
    void help(_, __, ___) {
      Globals.applicationRoutes.gotoAbout();
    }

    return addMenuItem(label, Icons.help, help);
  }

  Widget build(BuildContext context, T? arg, int? index) {
    if (applicableCallback == null || applicableCallback!(arg, index)) {
      var menuEntries = List<PopupMenuEntry<MenuCallbackFunction>>.empty(growable: true);
      for (var menuItem in menuItems) {
        if (menuItem == null) {
          menuEntries.add(const PopupMenuDivider());
        } else if (menuItem.isApplicable(arg, index)) {
          menuEntries.add(PopupMenuItem<MenuCallbackFunction>(
            value: (BuildContext context, arg, index) {
              menuItem.callback != null ? menuItem.callback!(context, arg, index) : null;
            },
            enabled: menuItem.valueListenable != null ? _shouldEnable(menuItem.valueListenable!.value) : true,
            child: ListTile(leading: Icon(menuItem.iconData), title: Text(menuItem.label)),
          ));
        }
      }

      if (menuEntries.isNotEmpty) {
        return PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) {
            return menuEntries;
          },
          onSelected: (MenuCallbackFunction<T>? callback) => {callback != null ? callback(context, arg, index) : null},
        );
      }
    }
    return const SizedBox();
  }

  bool _shouldEnable(value) {
    if (value == null) {
      return false;
    }

    if (value is SelectedItemPositions && value.positions.isNotEmpty) {
      return true;
    }

    if (value is List && value.isNotEmpty) {
      return true;
    }

    if (value is Set && value.isNotEmpty) {
      return true;
    }

    if (value is bool && value) {
      return true;
    }

    if (value is int || value is double && value != 0) {
      return true;
    }

    return false;
  }
}
