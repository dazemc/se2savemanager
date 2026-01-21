import 'dart:async';

import 'package:watcher/watcher.dart';

class SaveWatcher {
  final String watchPath;
  final void Function(String path) onChange;

  StreamSubscription _sub;

  SaveWatcher({required this.watchPath, required this.onChange})
    : _sub = DirectoryWatcher(watchPath).events.listen((event) {
        if (event.type != ChangeType.REMOVE &&
            event.path.contains('.container-info')) {
          onChange(event.path);
        }
      });
  void start() {
    _sub = _initStream();
  }

  Future<void> stop() async {
    await _sub.cancel();
  }

  void togglePause() {
    _sub.isPaused ? _sub.resume() : _sub.pause();
  }

  StreamSubscription _initStream() =>
      DirectoryWatcher(watchPath).events.listen((event) {
        if (event.type != ChangeType.REMOVE &&
            event.path.contains('.container-info')) {
          onChange(event.path);
        }
      });
}
