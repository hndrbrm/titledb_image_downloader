// Copyright 2022. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:tint/tint.dart';

import 'title.dart';

final class ImageDownloader {
  const ImageDownloader(this.directory);

  final Directory directory;

  static const String bannerPath = 'banner';
  static const String iconPath = 'icon';
  static const String screenshotPath = 'screenshot';

  Future<void> download(Title title) async {
    if (title.bannerUrl != null) {
      await downloadBanner(title.bannerUrl!);
    }

    if (title.iconUrl != null) {
      await downloadIcon(title.iconUrl!);
    }

    if (title.screenshots != null && title.screenshots!.isNotEmpty) {
      await downloadScreenshots(title.screenshots!);
    }
  }

  Future<void> downloadBanner(String url) async {
    final dir = Directory(join(directory.path, bannerPath));
    final uri = Uri.parse(url);
    await _download(dir, uri, 'banner');
  }

  Future<void> downloadIcon(String url) async {
    final dir = Directory(join(directory.path, iconPath));
    final uri = Uri.parse(url);
    await _download(dir, uri, 'icon');
  }

  Future<void> downloadScreenshots(Set<String> urls) async {
    final dir = Directory(join(directory.path, screenshotPath));
    for (final url in urls) {
      final uri = Uri.parse(url);
      await _download(dir, uri, 'screenshot');
    }
  }

  Future<void> _download(Directory directory, Uri uri, String tag) async {
    if (!await directory.exists()) {
      stdout.write('''${'Creating'.yellow()} ${tag.blue()} ${'directory'.yellow()} ${directory.path.gray()}... ''');
      await directory.create(recursive: true);
      stdout.writeln('OK'.green());
    }

    final filename = uri.pathSegments.last;
    final file = File(join(directory.path, filename));

    if (await file.exists()) {
      stdout.write('''${'Check'.yellow()} ${tag.blue()} ${'hash'.yellow()} ${filename.gray()}... ''');
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes);
      if (hash.toString() == filename.split('.').first) {
        stdout.writeln('OK'.green());
        return;
      } else {
        stdout.writeln('NG'.red());
      }
    }

    stdout.write('''${'Download'.yellow()} ${tag.blue()} ${filename.gray()}... ''');
    final response = await get(uri);
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      stdout.writeln('OK'.green());
    } else {
      stdout.writeln('NG'.red());
    }
  }
}
