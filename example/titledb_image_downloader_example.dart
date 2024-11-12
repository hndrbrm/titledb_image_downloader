// Copyright 2022. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';
import 'package:titledb_image_downloader/src/image_downloader.dart';
import 'package:titledb_image_downloader/titledb_image_downloader.dart';

Future<void> main() async {
  final titleDbDirectory = Directory('/Users/buba/Hiatus/switch/document/titledb/source');
  final downloadDirectory = Directory('/Users/buba/Downloads/ns');

  final titleDb = TitleDb(titleDbDirectory);
  final regions = await titleDb.loadRegions();
  final Languages languages = await titleDb.loadLanguages();

  for (final regionCode in regions.keys) {
    for (final countryCode in regions[regionCode]!) {
      for (final language in languages[countryCode] ?? <LanguageCode>[]) {
        final json = await titleDb.loadTitle(countryCode, language);

        for (final key in json.keys) {
          final Map<String, dynamic> value = json[key];
          final title = Title.fromJson(value, language);

          final directory = Directory(join(downloadDirectory.path, '${title.nsuId}'));
          await ImageDownloader(directory).download(title);
        }
      }
    }
  }
}
