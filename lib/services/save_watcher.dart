import 'dart:async';

import 'package:watcher/watcher.dart';

class SaveWatcher {
  final String watchPath;
  final void Function(String path) onChange;

  late final StreamSubscription _sub;

  SaveWatcher({required this.watchPath, required this.onChange});
  void start() {
    final watcher = DirectoryWatcher(watchPath);
    _sub = watcher.events.listen((event) {
      if (event.type != ChangeType.REMOVE &&
          event.path.contains('.container-info')) {
        onChange(event.path);
      }
    });
  }

  void stop() {
    _sub.cancel();
  }

  void restart() {
    _sub.cancel();
    start();
  }
}
