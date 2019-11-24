import 'package:dshell/util/dshell_exception.dart';

import 'commands/commands.dart';
import 'commands/run.dart';
import 'flags.dart';

class CommandLineRunner {
  static CommandLineRunner _self;
  List<Flag> availableFlags;
  Map<String, Command> availableCommands;

  // the list of flags selected via the cli.
  Map<String, Flag> selectedFlags = Map();

  factory CommandLineRunner() {
    if (_self == null) {
      throw Exception("The CommandLineRunner has not been intialised");
    }
    return _self;
  }

  bool get isVerbose => Flags.isSet(VerboseFlag(), selectedFlags);

  static void init(List<Flag> availableFlags, List<Command> availableCommands) {
    _self = CommandLineRunner.internal(
        availableFlags, Commands.asMap(availableCommands));
  }

  CommandLineRunner.internal(this.availableFlags, this.availableCommands);

  int process(List<String> arguments) {
    int exitCode;

    bool success = false;

    // Find the command and run it.
    Command command;

    int i = 0;
    for (; i < arguments.length; i++) {
      final String argument = arguments[i];

      if (Flags.isFlag(argument)) {
        Flag flag = Flags.findFlag(argument, availableFlags);

        if (flag != null) {
          if (selectedFlags.containsKey(flag.name)) {
            throw DuplicateOptionsException(argument);
          }
          selectedFlags[flag.name] = flag;
          continue;
        } else {
          throw UnknownFlag(argument);
        }
      }

      // there may only be one command on the cli.
      command = Commands.findCommand(argument, availableCommands);
      if (command != null) {
        success = true;
        break;
      }

      // its not a flag, its not a command, so it must be a script.
      command = RunCommand();
      success = true;
      break;
    }

    if (success) {
// get the script name and remaning args as they are the arguments for the command to process.
      List<String> cmdArguments = List();

      if (i + 1 < arguments.length) {
        cmdArguments = arguments.sublist(i);
      }

      exitCode = command.run(selectedFlags.values.toList(), cmdArguments);
    } else {
      usage();

      throw InvalidArguments("Invalid arguments passed.");
    }
    return exitCode;
  }

  void usage() {}
}

class CommandLineException extends DShellException {
  CommandLineException(String message) : super(message);
}

class OptionsException extends CommandLineException {
  OptionsException(String message) : super(message);
}

class DuplicateOptionsException extends OptionsException {
  final String optionName;

  DuplicateOptionsException(this.optionName)
      : super('Option ${optionName} used twice!');
  String toString() => message;
}

class UnknownOption extends OptionsException {
  final String optionName;

  UnknownOption(this.optionName) : super('The option $optionName is unknown!');

  String toString() => message;
}

class InvalidScript extends CommandLineException {
  InvalidScript(String message) : super(message);
}

class UnknownCommand extends CommandLineException {
  final String command;

  UnknownCommand(this.command)
      : super(
            "The command ${command} was not recognised. Scripts must end with .dart!");
}

class UnknownFlag extends CommandLineException {
  final String flag;

  UnknownFlag(this.flag) : super("The flag ${flag} was not recognised!");

  String toString() => message;
}

class InvalidArguments extends CommandLineException {
  InvalidArguments(String message) : super(message);
}