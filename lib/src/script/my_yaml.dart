import 'dart:cli';
import 'dart:io';

import 'package:yaml/yaml.dart' as y;
import 'dependency.dart';

/// wrapper for the YamlDocument
/// designed to make it easier to read yaml files.
class MyYaml {
  late final y.YamlDocument _document;

  /// read yaml from string
  MyYaml.fromString(String content) {
    _document = _load(content);
  }

  /// returns the raw content of the yaml file.
  String get content => _document.toString();

  /// reads yaml from file.
  MyYaml.fromFile(String path) {
    var contents = waitFor<String>(File(path).readAsString());
    _document = _load(contents);
  }

  y.YamlDocument _load(String content) {
    return y.loadYamlDocument(content);
  }

  /// Reads the value of the given key.
  /// Returns an empty string if the key doesn't exist.
  ///
  String getValue(String key) {
    if (_document.contents.value == null) {
      return '';
    } else {
      return _document.contents.value[key] as String;
    }
  }

  /// returns the list of elements attached to [key]
  /// or an empyt list of the key doesn't exist.
  y.YamlList getList(String key) {
    if (_document.contents.value == null) {
      return y.YamlList();
    } else {
      return _document.contents.value[key] as y.YamlList;
    }
  }

  /// returns the map of elements attached to [key]
  /// or an empty map if the key doesn't exist.
  y.YamlMap getMap(String key) {
    if (_document.contents.value == null) {
      return y.YamlMap();
    } else {
      return _document.contents.value[key] as y.YamlMap;
    }
  }

  /// addes a list to the yaml.
  void setList(String key, List<Dependency> list) {
    _document.contents.value[key] = list;
  }
}
