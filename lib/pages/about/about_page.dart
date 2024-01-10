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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mopicon/components/error_snackbar.dart';
import 'package:mopicon/components/material_page_frame.dart';
import 'package:mopicon/components/titled_divider.dart';
import 'package:mopicon/generated/l10n.dart';
import 'package:mopicon/services/preferences_service.dart';
import 'package:url_launcher/url_launcher.dart';

var license = '''
https://en.wikipedia.org/wiki/MIT_License[The MIT License (MIT)]

Copyright \u00a9 2023 Thomas Kern
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
''';

/// Displays information about this program, with links to sourcecode
/// and documentation.
class AboutPage extends StatelessWidget {
  final _preferences = GetIt.instance<Preferences>();

  AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(S.of(context).aboutPageTitle),
        ),
        body: MaterialPageFrame(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              title('MOPICON'),
              paragraph(context, 'Copyright \u00a9 2023 Thomas Kern', fontSize: 14, textAlign: TextAlign.center),
              paragraph(context, S.of(context).aboutPageDescription, fontSize: 14, textAlign: TextAlign.center),
              TitledDivider(S.of(context).aboutPageVersionSection),
              paragraph(context, _preferences.version, fontSize: 14, textAlign: TextAlign.center),
              TitledDivider(S.of(context).aboutPageHelpSection),
              paragraph(context, S.of(context).aboutPageHelpDescription, fontSize: 14, textAlign: TextAlign.center),
              TitledDivider(S.of(context).aboutPageLicenseSection),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: paragraph(context, license, fontSize: 11))
            ],
          ),
        )));
  }

  Widget paragraph(BuildContext context, String text, {TextAlign? textAlign, double? fontSize}) {
    return Padding(
        padding: const EdgeInsets.only(top: 10), //apply padding to all four sides
        child: Text.rich(
            softWrap: true,
            TextSpan(
              children: textSpans(context, text),
              style: TextStyle(fontSize: fontSize ?? 14, fontWeight: FontWeight.normal),
            ),
            textAlign: textAlign ?? TextAlign.start));
  }

  Widget title(String text) {
    return Text.rich(
      softWrap: true,
      TextSpan(text: text, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      textAlign: TextAlign.center,
    );
  }

  List<InlineSpan> textSpans(BuildContext context, String text) {
    var spans = List<InlineSpan>.empty(growable: true);

    // Find links within the text and convert parts
    // into text spans.
    RegExp namedLink = RegExp(
      r"(HTTP|HTTPS)(://\S+)\[([^\]]+)\]",
      caseSensitive: false,
      multiLine: false,
    );

    var currentPos = 0;
    var matches = namedLink.allMatches(text);
    if (matches.isNotEmpty) {
      for (var match in matches) {
        spans.add(TextSpan(text: text.substring(currentPos, match.start)));
        spans.add(TextSpan(
          text: match[3],
          style: const TextStyle(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              Uri url = Uri.parse('${match[1]}${match[2]}');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  showError(S.of(context).aboutPageLinkLaunchError(url.toString()), null);
                }
              }
            },
        ));
        currentPos = match.end;
      }
    }
    spans.add(TextSpan(text: text.substring(currentPos, text.length)));
    return spans;
  }
}
