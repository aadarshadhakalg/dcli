@t.Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

import '../util/test_file_system.dart';

void main() {
  // can't be run from within vscode as it needs console input.
  t.group('Read from stdin', () {
    t.test('Read and then write ', () {
      TestFileSystem().withinZone((fs) {
        readStdin().forEach(print);
      });
    }, skip: true);
  });
}
