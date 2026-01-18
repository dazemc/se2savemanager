import 'dart:io';

import 'package:hive_ce/hive_ce.dart';
import 'package:logging/logging.dart';
import 'package:se2savemanager/models/save.dart';
import 'package:se2savemanager/services/save_watcher.dart';

import 'save_logger.dart';

class SaveManager {
  //TODO: Linux
  final Logger _log = SaveLogger(name: 'SaveManager').log;
  final String installationDirectoryPath;
  final String spaceEngineersSaveDirectoryPath;
  final Future<void> Function(String) onChange;
  late final Directory _spaceEngineersSaveDirectory;
  late final Box box;

  late final SaveWatcher watcher;
  SaveManager({required this.onChange})
    : installationDirectoryPath = Platform.isWindows
          ? '${Platform.environment["APPDATA"]!}/se2savemanager'
          : '',
      spaceEngineersSaveDirectoryPath = Platform.isWindows
          ? '${Platform.environment["APPDATA"]!}/SpaceEngineers2/AppData/SaveGames'
          : '' {
    _spaceEngineersSaveDirectory = Directory(spaceEngineersSaveDirectoryPath);
  }

  Future<void> init() async {
    await _install();
    await _initBox();
    readLocalSaves();
    watcher = SaveWatcher(
      watchPath: spaceEngineersSaveDirectoryPath,
      //TODO: Pass function
      onChange: (path) async => await _eventHandlerWrapper(onChange, path),
    );
  }

  Future<void> reload() async {
    await _install();
    await _resetLocalSaveStorage();
  }

  void readLocalSaves() {
    final saves = box.get('localSaves');
    _log.info('Current saves: $saves');
  }

  Future<List<Save>> getLocalSaves() async {
    final savesRaw = box.get('localSaves') as Map<String, String>;
    final saves = <Save>[];
    for (String path in savesRaw.values) {
      saves.add(await Save.fromPath(path));
    }
    return saves;
  }

  Future<void> _initBox() async {
    Hive.init(installationDirectoryPath);
    box = await Hive.openBox('se2savemanager');
    await _resetLocalSaveStorage();
  }

  Future<void> _resetLocalSaveStorage() async {
    Map<String, String> saves = {};
    await for (FileSystemEntity e in _spaceEngineersSaveDirectory.list()) {
      if (await File('${e.path}/.container-info').exists() && e is Directory) {
        final save = await Save.fromDirectory(e);
        saves[save.container.value.containerMeta.displayName] = e.path;
      }
    }
    box.put('localSaves', saves);
  }

  Future<void> _eventHandlerWrapper(
    Future<void> Function(String) eventHandler,
    String path,
  ) async {
    watcher.togglePause();
    await eventHandler(path);
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
