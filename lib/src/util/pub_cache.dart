import 'dart:io';

import '../../dshell.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  static PubCache _self = PubCache._internal();

  String _pubCacheDir;
  String _pubCacheBinDir;
  static const String _pubCacheEnv = 'PUB_CACHE';
  String _pubCachePath;

  ///
  factory PubCache() {
    return _self;
  }

  PubCache._internal() : _pubCacheDir = '.pub-cache' {
    // first check if an environment variable exists.
    String? pubCacheEnv = env(_pubCacheEnv);

    /// determine pubCacheDir
    if (pubCacheEnv != null) {
      _pubCacheDir = dirname(pubCacheEnv);
    }

    if (Platform.isWindows) {
      _pubCacheDir = join('Pub', 'Cache');
    }

    // determine pub-cache path
    if (pubCacheEnv != null) {
      _pubCachePath = pubCacheEnv;
    } else {
      _pubCachePath = truepath(join(HOME, _pubCacheDir));
    }

    // determine pub-cache/bin
    _pubCacheBinDir = truepath(join(_pubCachePath, 'bin'));
  }

  /// The fully qualified path to the pub cache.
  ///
  /// Dart allows the user to modify the location of
  /// the .pub-cache by setting the environment var
  /// PUB_CACHE.
  ///
  /// This method processes PUB_CACHE if it exists.
  String get path => _pubCachePath;

  /// Returns the path to the .pub-cache's bin directory
  /// where executables from installed packages are stored.
  String get binPath => _pubCacheBinDir;

  /// Returns the directory name of the pub cache.
  ///
  /// Dart allows the user to modify the location of
  /// the .pub-cache by setting the environment var
  /// PUB_CACHE.
  ///
  /// This method processes PUB_CACHE if it exists.
  String get cacheDir => _pubCacheDir;

  /// only to be used for unit tests.
  /// It resets the paths so that they can pick
  /// up changes to HOME made by the unit tests.
  static void unitTestreset() {
    _self = null;
  }
}
