import 'dart:async';

import 'package:se2savemanager/services/save_logger.dart';
import 'package:watcher/watcher.dart';
import 'package:logging/logging.dart';

class SaveWatcher {
  final String watchPath;
  final void Function(String path) onChange;
  final Logger _log = SaveLogger(name: 'Save Watcher').log;
  bool isRunning = true;

  StreamSubscription _sub;

  SaveWatcher({required this.watchPath, required this.onChange})
    : _sub = DirectoryWatcher(watchPath).events.listen((event) {
        if (event.type != ChangeType.REMOVE &&
            event.path.contains('.container-info')) {
          onChange(event.path);
        }
      });
  void start() {
    if (!isRunning) {
      _sub = _initStream();
      isRunning = true;
      _log.info('Save Watcher started');
    }
  }

  Future<void> stop() async {
    if (isRunning) {
      await _sub.cancel();
      isRunning = false;
      _log.info('Save Watcher stopped');
    }
  }

  void togglePause() {
    _sub.isPaused ? _sub.resume() : _sub.pause();
    _log.info('Save Watcher paused');
  }

  StreamSubscription _initStream() =>
      DirectoryWatcher(watchPath).events.listen((event) {
        if (event.type != ChangeType.REMOVE &&
            event.path.contains('.container-info')) {
          onChange(event.path);
        }
      });
}
