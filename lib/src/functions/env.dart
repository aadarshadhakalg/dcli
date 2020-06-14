import 'dart:io';

import 'package:collection/collection.dart';
import '../../dshell.dart';
import '../settings.dart';
import '../util/dshell_exception.dart';

import 'dshell_function.dart';

/// Returns the value of an environment variable.
///
/// [name] of the enviornment variable.
///
/// On posix systems [name] is case sensitive.
///
/// If the environment variable doesn't exists
/// then [null] is returned.
///
///```dart
///String path = env("PATH");
///```
///
String env(String name) => Env()._env(name);

/// Tests if the given [path] is contained
/// in the OS's PATH environment variable.
/// An canonicalized match of [path] is made against
/// each path on the OS's path.
bool isOnPath(String path) => Env().isOnPath(path);

/// Returns the list of directory paths that are contained
/// in the OS's PATH environment variable.
/// They are returned in the same order that they appear within
/// the PATH environment variable (as order is important.)
//ignore: non_constant_identifier_names
List<String> get PATH => Env()._path;

/// returns the path to the OS specific HOME directory
//ignore: non_constant_identifier_names
String get HOME => Env().HOME;

/// Returns a map of all the environment variables
/// inherited from the parent as well as any changes
/// made by calls to [setEnv].
///
/// See [env]
///     [setEnv]
Map<String, String> get envs => Env()._envVars;

///
/// Sets an environment variable for the current process.
///
/// Any child processes spawned will inherit these changes.
/// e.g.
/// ```
///   setEnv('XXX', 'A Value');
///   // the echo command will display the value off XXX.
///   '''echo $XXX'''.run;
///
/// ```
/// NOTE: this does NOT affect the parent
/// processes environment.
void setEnv(String name, String value) => Env().setEnv(name, value);

/// Implementation class for the functions [_env] and [setEnv].
class Env extends DShellFunction {
  static Env _self = Env._internal();

  var _envVars = <String, String>{};

  bool _caseSensitive = true;

  /// Implementation class for the functions [_env] and [setEnv].
  factory Env() {
    return _self;
  }

  Env._internal() {
    var platformVars = Platform.environment;

    if (Settings().isWindows) {
      _caseSensitive = false;
    }

    _envVars =
        CanonicalizedMap((key) => (_caseSensitive) ? key : key.toUpperCase());

    // build a local map with all of the OS environment vars.
    for (var entry in platformVars.entries) {
      _envVars.putIfAbsent(entry.key, () => entry.value);
    }
  }

  /// conveience method for unit tests.
  /// resets all environment variables to the state
  /// we inheritied from the parent process.
  static void reset() {
    _self = Env._internal();
  }

  String? _env(String name) {
    Settings().verbose('env:  $name:${_envVars[name]}');

    return _envVars[name];
  }

  /// returns the path seperator used by the PATH enviorment variable.
  ///
  /// On linix it is ':' ond windows it is ';'
  ///
  /// NOTE do NOT confuses this with the file system path root!!!
  ///
  String get pathSeparator {
    var separator = ':';

    if (Platform.isWindows) {
      separator = ';';
    }
    return separator;
  }

  /// returns the PATH environment var.
  List<String> get _path {
    var pathEnv = _env('PATH');

    return pathEnv.split(pathSeparator);
  }

  ///
  /// Gets the path to the users home directory
  /// using the enviornment var appropriate for the user's OS.
  //ignore: non_constant_identifier_names
  String get HOME {
    String? home;

    if (Settings().isWindows) {
      home = _env('APPDATA');
    } else {
      home = _env('HOME');
    }

    if (home == null) {
      if (Settings().isWindows) {
        throw DShellException(
            "Unable to find the 'APPDATA' enviroment variable. Please ensure it is set and try again.");
      } else {
        throw DShellException(
            "Unable to find the 'HOME' enviroment variable. Please ensure it is set and try again.");
      }
    }
    return home;
  }

  /// returns true if the given [path] is in the list
  /// of paths defined in the environment variable [PATH].
  bool isOnPath(String checkPath) {
    var canon = canonicalize(absolute(checkPath));
    var found = false;
    for (var path in _path) {
      if (canonicalize(path) == canon) {
        found = true;
        break;
      }
    }
    return found;
  }

  /// Passing a null [value] will remove the key from the
  /// set on environment variables.
  void setEnv(String name, String? value) {
    if (value == null) {
      _envVars.remove(name);
      if (Platform.isWindows) {
        if (name == 'HOME' || name == 'APPDATA') {
          _envVars.remove('HOME');
          _envVars.remove('APPDATA');
        }
      }
    } else {
      _envVars[name] = value;

      if (Platform.isWindows) {
        if (name == 'HOME' || name == 'APPDATA') {
          _envVars['HOME'] = value;
          _envVars['APPDATA'] = value;
        }
      }
    }
  }

  /// Used in unit tests to mock the Env class.
  // ignore: avoid_setters_without_getters
  static set mock(Env mockEnv) {
    _self = mockEnv;
  }
}
