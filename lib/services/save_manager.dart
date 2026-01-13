import 'dart:io';

import 'package:hive_ce/hive_ce.dart';
import 'package:logging/logging.dart';
import 'package:se2savemanager/models/container_info.dart';
import 'package:se2savemanager/models/save.dart';
import 'package:se2savemanager/models/save_meta.dart';
import 'package:se2savemanager/services/save_watcher.dart';

import 'save_logger.dart';

class SaveManager {
  //TODO: Linux
  final Logger _log = SaveLogger(name: 'SaveManager').log;
  final String installationDirectoryPath;
  final String spaceEngineersSaveDirectoryPath;
  late final Box box;

  late final SaveWatcher watcher;
  SaveManager()
    : installationDirectoryPath = Platform.isWindows
          ? '${Platform.environment["APPDATA"]!}/se2savemanager'
          : '',
      spaceEngineersSaveDirectoryPath = Platform.isWindows
          ? '${Platform.environment["APPDATA"]!}/SpaceEngineers2/AppData/SaveGames'
          : '';

  Future<void> init() async {
    await _install();
    Hive.init(installationDirectoryPath);
    box = await Hive.openBox('se2savemanager');
    watcher = SaveWatcher(
      watchPath: spaceEngineersSaveDirectoryPath,
      onChange: (path) => _eventHandler(path),
    );
  }

  Future<void> _eventHandler(String path) async {
    watcher.togglePause();
    final Directory dir = .new(path).parent;
    if (await dir.exists()) {
      final save = await Save.fromDirectory(dir);
      _log.info(
        "loaded save: '${save.container.value.containerMeta.displayName}', path: '${save.dir.path}'",
      );
    }
    watcher.togglePause();
  }

  Future<void> _install() async {
    if (installationDirectoryPath.isNotEmpty) {
      final dir = Directory(installationDirectoryPath);
      if (await dir.exists()) {
        _log.info('se2savemanager already installed');
        //TODO: give option to uninstall/reinstall
        return;
      } else {
        await dir.create();
      }
      if (!await dir.exists()) {
        final msg =
            'Could not create se2savemanager directory at location: $dir';
        _log.severe(msg);
        throw msg;
      }
    }
  }
}
