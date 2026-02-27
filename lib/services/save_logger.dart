import 'package:logging/logging.dart';
import 'dart:io';

class SaveLogger {
  static bool _init = false;
  Logger log;
  Level level;
  final String name;
  File? logfile;
  SaveLogger({this.name = 'Log', this.level = Level.ALL}) : log = Logger(name) {
    if (!_init) {
      Logger.root.level = level;
      Logger.root.onRecord.listen((m) {
        String msg =
            '${m.time}: '
            '${m.level.name}: '
            '${m.loggerName}: '
            '${m.message}';
        stdout.writeln(msg);
        writeFile(logfile, msg);
      });
      _init = true;
    }
  }

  Future<void> writeFile(File? logfile, String msg) async {
    if (logfile != null) {
      if (await logfile.exists()) {
        logfile.writeAsString(msg, mode: .append);
      }
    }
  }
}
