import 'package:yaml/yaml.dart';

import '../script/dependency.dart';
import '../script/my_yaml.dart';

mixin DependenciesMixin {
  /// List of dependencis in the given yaml.
  late List<Dependency> dependencies = _extractDependencies(yaml);

  String get name => yaml.getValue('name');
  String get version => yaml.getValue('version');

  MyYaml get yaml;

  List<Dependency> _extractDependencies(MyYaml yaml) {
    var dependencies = <String, Dependency>{};
    var map = yaml.getMap('dependencies');

    if (map != null) {
      for (var entry in map.entries) {
        Dependency dependency;
        if (entry.value is String) {
          dependency =
              Dependency.fromHosted(entry.key as String, entry.value as String);
        } else {
          var path = (entry.value as YamlMap)['path'] as String;
          dependency = Dependency.fromPath(entry.key as String, path);
        }
        dependencies[dependency.name] = dependency;
      }
    }

    var overrides = yaml.getMap('dependency_overrides');
    if (overrides != null) {
      for (var entry in overrides.entries) {
        var path = (entry.value as YamlMap)['path'] as String;
        var dependency = Dependency.fromPath(entry.key as String, path);
        dependencies[dependency.name] = dependency;
      }
    }

    return dependencies.values.toList();
  }
}
