#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// globally activates dcli from a local path rather than a public package.
///
///
void main(List<String> args) {
  final root = Script.current.pathToProjectRoot;
  'dart pub global activate dcli --source=path'
      .start(workingDirectory: dirname(root));
  'dcli install'.start();
  'dart pub global activate dcli --source=path'
      .start(workingDirectory: dirname(root));
}
