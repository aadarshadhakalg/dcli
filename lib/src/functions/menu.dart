import 'dart:math';

import '../../dshell.dart';
import '../script/command_line_runner.dart';

/// Displays a menu with each of the provided [options], prompts
/// the user to select an option and returns the selected option.
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu(prompt: 'Please select a color', options: colors);
/// ```
/// Results in:
///```
/// 1) Red
/// 2) Green
/// Please select a color:
/// ```
///
/// [menu] will display an error if the user enters a non-valid
/// response and then redisplay the prompt.
///
/// Once a user selects a valid option, that option is returned.
///
/// You may provide a [limit] which will cause the
/// menu to only display the first [limit] options passed.
///
/// If you pass a [format] lambda then the [format] function
/// will be called for for each option and the resulting format
/// used to display the option in the menu.
///
/// e.g.
/// ```dart
///
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu(prompt: 'Please select a color', options: colors, format: (color) => color.name);
/// ```
///
/// If [format] is null then [option.toString()] will be used
/// as the format for the menu option.
///
/// When a [limit] is applied the menu will display the first [limit]
/// options. If you specify [fromStart: false] then the menu will display the
/// last [limit] options.
///

T menu<T>(
    {required String prompt,
    required List<T> options,
    int limit = -1,
    String Function(T) format = _plain<T>,
    bool fromStart = true}) {
  if (options.isEmpty) {
    throw InvalidArguments(
        'The list of [options] passed to menu(options: ) was empty.');
  }
  if (limit == -1) limit = options.length;

  var displayList = options;
  if (fromStart == false) {
    // get the last [limit] options
    displayList = options.sublist(min(options.length, options.length - limit));
  }

  // display each option.
  for (var i = 1; i <= limit; i++) {
    var option = displayList[i - 1];
    var desc = format(option);
    var no = '$i'.padLeft(3);
    print('$no) $desc');
  }

  var valid = false;

  var index = -1;

  // loop until the user enters a valid selection.
  while (!valid) {
    var selected = ask(prompt: prompt);

    var tmp = int.tryParse(selected);
    if (tmp == null) {
      printerr('Value must be an integer from 1 to $limit');
      continue;
    }
    index = tmp;

    if (index < 1 || index > limit) {
      printerr('Invalid selection');
      continue;
    }
    valid = true;
  }
  return options[index - 1];
}

String _plain<T>(T object) => object.toString();
