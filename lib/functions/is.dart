import 'dart:io';

import 'package:dshell/functions/function.dart';

///
/// Returns true if the given path points to a file.
///
/// ```dart
/// isFile("~/fred.jpg");
/// ```
bool isFile(String path) => Is().isFile(path);

/// Returns try if the given path is a directory.
/// ```dart
/// isDirectory("/tmp");
///
/// ```
bool isDirectory(String path) => Is().isDirectory(path);

/// returns true if the given path exists.
/// It may be a file or a directory.
/// ```dart
/// if (exists("/fred.txt"))
/// ```
bool exists(String path) => Is().exists(path);

class Is extends DShellFunction {
  bool isFile(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.file);
  }

  /// true if the given path is a directory.
  bool isDirectory(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.directory);
  }

  /// checks if the given [path] exists.
  bool exists(String path) {
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }
}