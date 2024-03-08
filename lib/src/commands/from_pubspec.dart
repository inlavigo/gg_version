// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:gg_args/gg_args.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

// #############################################################################
/// Provides "ggGit current-version-tag <dir>" command
class FromPubspec extends GgDirCommand {
  /// Constructor
  FromPubspec({
    required super.log,
  });

  // ...........................................................................
  @override
  final name = 'from-pubspec';
  @override
  final description = 'Returns the version found in pubspec.yaml';

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
    final pubspec = File('${directory.path}/pubspec.yaml');
    final dirName = basename(canonicalize(directory.path));

    if (!pubspec.existsSync()) {
      throw Exception('File "$dirName/pubspec.yaml" does not exist.');
    }

    return fromString(content: await pubspec.readAsString());
  }

  // ...........................................................................
  /// Parses version from pubspec.yaml
  static Version fromString({
    required String content,
  }) {
    late Pubspec pubspec;

    try {
      pubspec = Pubspec.parse(content);
    } on ParsedYamlException catch (e) {
      throw Exception(e.message);
    }

    if (pubspec.version == null) {
      throw Exception('Could not find version in "pubspec.yaml".');
    }

    return pubspec.version!;
  }
}