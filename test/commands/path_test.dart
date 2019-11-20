import 'dart:io';

import 'package:dshell/util/log.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";
import 'package:path/path.dart' as p;

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;
  String cwd = pwd;
  String TEST_DIR = "path_test";

  // can't be run in parallel to other tests as it chana
  try {
    t.group("Directory Path manipulation testing", () {
      String home = env("HOME");
      String pathTestDir = join(TEST_ROOT, TEST_DIR, "pathTestDir");
      String testExtension = ".jpg";
      String testBaseName = "fred";
      String testFile = "$testBaseName$testExtension";

      t.test("absolute", () {
        String cwd = pwd;

        t.expect(absolute(pathTestDir), t.equals(join(cwd, pathTestDir)));
      });

      t.test("parent", () {
        t.expect(dirname(pathTestDir), t.equals(join(TEST_ROOT, TEST_DIR)));
      });

      t.test("extension", () {
        t.expect(
            extension(join(pathTestDir, testFile)), t.equals(testExtension));
      });

      t.test("basename", () {
        t.expect(basename(join(pathTestDir, testFile)), t.equals(testFile));
      });

      t.test("PWD", () {
        t.expect(pwd, t.startsWith(home));
      });

      t.test("CD", () {
        String testdir = pwd;

        TestDirectoryOverride dirOverride = TestDirectoryOverride();
        IOOverrides.runZoned(() {
          createDir("cd_test");
          cd("cd_test");
          t.expect(pwd, t.equals(absolute(join(testdir, "cd_test"))));
          cd("..");
          t.expect(pwd, t.equals(absolute(cwd)));

          cd(cwd);
          t.expect(pwd, t.equals(cwd));
        },
            createDirectory: (path) => dirOverride.createDir(path),
            setCurrentDirectory: (path) =>
                dirOverride.current = TestDirectory(path),
            getCurrentDirectory: () => dirOverride.current);
      });

      t.test("Push/Pop", () {
        TestDirectoryOverride dirOverride = TestDirectoryOverride();
        IOOverrides.runZoned(() {
          String start = pwd;
          createDir(pathTestDir, createParent: true);

          String expectedPath = absolute(pathTestDir);
          push(pathTestDir);
          t.expect(pwd, t.equals(expectedPath));

          pop();
          t.expect(pwd, t.equals(start));

          deleteDir(pathTestDir, recursive: true);
        },
            createDirectory: (path) => dirOverride.createDir(path),
            setCurrentDirectory: (path) =>
                dirOverride.current = TestDirectory(path),
            getCurrentDirectory: () => dirOverride.current);
      });

      t.test("Too many pops", () {
        t.expect(() => pop(), t.throwsA(t.TypeMatcher<PopException>()));
      });
    });
  } finally {
    cd(cwd);
  }
}

class TestDirectoryOverride {
  Directory _current = TestDirectory(canonicalize("."));

  Set<String> paths = Set();
  TestDirectoryOverride();

  Directory get current => _current;

  set current(Directory current) {
    _current = current;
    Log.d("DirectoryOverride current=" + current.path);
  }

  Directory createDir(String path) {
    paths.add(path);

    return TestDirectory(path);
  }
}

class TestDirectory implements Directory {
  String _path;

  TestDirectory(String path) : _path = p.canonicalize(path);

  @override
  Directory get absolute => this;

  @override
  Future<Directory> create({bool recursive = false}) {
    return null;
  }

  @override
  void createSync({bool recursive = false}) {}

  @override
  Future<Directory> createTemp([String prefix]) {
    return null;
  }

  @override
  Directory createTempSync([String prefix]) {
    return null;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    return null;
  }

  @override
  void deleteSync({bool recursive = false}) {}

  @override
  Future<bool> exists() {
    return null;
  }

  @override
  bool existsSync() {
    return null;
  }

  @override
  bool get isAbsolute => null;

  @override
  Stream<FileSystemEntity> list(
      {bool recursive = false, bool followLinks = true}) {
    return null;
  }

  @override
  List<FileSystemEntity> listSync(
      {bool recursive = false, bool followLinks = true}) {
    return null;
  }

  @override
  Directory get parent => null;

  @override
  String get path => _path;

  @override
  Future<Directory> rename(String newPath) {
    return null;
  }

  @override
  Directory renameSync(String newPath) {
    return null;
  }

  @override
  Future<String> resolveSymbolicLinks() {
    return null;
  }

  @override
  String resolveSymbolicLinksSync() {
    return null;
  }

  @override
  Future<FileStat> stat() {
    return null;
  }

  @override
  FileStat statSync() {
    return null;
  }

  @override
  Uri get uri => null;

  @override
  Stream<FileSystemEvent> watch(
      {int events = FileSystemEvent.all, bool recursive = false}) {
    return null;
  }
}