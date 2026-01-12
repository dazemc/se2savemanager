import 'package:logging/logging.dart';
import 'dart:io';

class SaveLogger {
  Logger log;
  Level level;
  final String name;
  SaveLogger({this.name = 'Log', this.level = Level.ALL}) : log = Logger(name) {
    Logger.root.level = level;
    Logger.root.onRecord.listen(
      (m) => stdout.writeln(
        '${m.time}: '
        '${m.level.name}: '
        '${m.loggerName}: '
        '${m.message}',
      ),
    );
  }
}
