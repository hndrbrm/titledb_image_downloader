// Copyright 2022. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:titledb_image_downloader/titledb_image_downloader.dart';

Future<void> main() async {
  final directory = Directory('/Users/buba/Hiatus/switch/document/titledb/source');
  final titleDb = TitleDb(directory);
  final regions = await titleDb.loadRegions();
  final Languages languages = await titleDb.loadLanguages();

  for (final regionCode in regions.keys) {
    for (final countryCode in regions[regionCode]!) {
      for (final language in languages[countryCode] ?? <LanguageCode>[]) {
        final json = await titleDb.loadTitle(countryCode, language);

        for (final key in json.keys) {
          final Map<String, dynamic> value = json[key];
          final title = Title.fromJson(value, language);
          print(title.toJson());
          exit(1);
        }
      }
    }
  }
}
