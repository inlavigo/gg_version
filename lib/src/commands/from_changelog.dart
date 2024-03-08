// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_args/gg_args.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';

// #############################################################################
/// Provides "ggGit current-version-tag <dir>" command
class FromChangelog extends GgDirCommand {
  /// Constructor
  FromChangelog({
    required super.log,
  });

  // ...........................................................................
  @override
  final name = 'from-changelog';
  @override
  final description = 'Returns the version found in CHANGELOG.md';

  // ...........................................................................
  @override
  Future<void> run() async {
    await super.run();

    final result = await fromDirectory(
      directory: inputDir,
    );

    log(result.toString());
  }

  // ...........................................................................
  /// Returns true if everything in the directory is pushed.
  static Future<Version> fromDirectory({required Directory directory}) async {
    await GgDirCommand.checkDir(directory: directory);
    final pubspec = File('${directory.path}/CHANGELOG.md');
    final dirName = basename(canonicalize(directory.path));

    if (!pubspec.existsSync()) {
      throw Exception('File "$dirName/CHANGELOG.md" does not exist.');
    }

    return fromString(content: pubspec.readAsStringSync());
  }

  // ...........................................................................
  /// Parses version from pubspec.yaml
  static Version fromString({
    required String content,
  }) {
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.startsWith('## ')) {
        final version = line.split(' ')[1].trim();
        try {
          return Version.parse(version);
        } catch (e) {
          throw Exception(
            'Version "$version" has invalid format.',
          );
        }
      }
    }

    throw Exception('Could not find version in "CHANGELOG.md".');
  }
}
