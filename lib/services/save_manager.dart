import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive_ce.dart';
import 'package:io/io.dart';
import 'package:logging/logging.dart';
import 'package:se2savemanager/models/managed_save.dart';
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

  Future<void> copySave(Save save) async {
    //TODO: check if parent and if null, then check/count children and add with path
    // will also need to check if path is in .backups at some point
    final name = save.container.value.containerMeta.displayName;
    final path = save.dir.path;
    final parent = box.get('managedSaves', defaultValue: {});
    parent[name] ?? _log.info('Copying unmanaged save');
    final newPath = '$path 2';
    _log.info('New path: $newPath');
    // copyPath(path, )
    // box.put('managedSaves', {
    //   name: {'path': path, 'children': {}},
    // });
    _log.info('Copying save: $name at $path');
  }

  Future<void> deleteSave(Save save) async {
    await save.dir.delete();
    await _resetLocalSaveStorage();
  }

  Future<List<Save>> getLocalSaves() async {
    final savesRaw = _getRawSaves();
    final saves = <Save>[];
    for (String path in savesRaw.values) {
      saves.add(await Save.fromPath(path));
    }
    return saves;
  }

  Future<void> init() async {
    await _install();
    await _initBox();
    readLocalSaves();
    watcher = SaveWatcher(
      watchPath: spaceEngineersSaveDirectoryPath,
      onChange: (path) async => await _eventHandlerWrapper(onChange, path),
    );
  }

  void readLocalSaves() {
    final saves = box.get('localSaves');
    _log.info('Current saves: $saves');
  }

  Future<void> reload() async {
    await _install();
    await _resetLocalSaveStorage();
  }

  Future<void> renameSave(String name, String newName) async {
    await watcher.stop();
    final savesRaw = _getRawSaves();
    final path = savesRaw[name];
    final save = await Save.fromPath(path!);
    _log.info('Renaming save at: $path');
    save.container.value.containerMeta.displayName = newName;
    JsonEncoder encoder = .withIndent(r'  ');
    final prettyPrint = encoder.convert(save.container.toJson());
    await File(
      '$path/.container-info',
    ).writeAsString(prettyPrint, mode: .write, flush: true);
    //TODO: retry loop
    await Future.delayed(const Duration(milliseconds: 50));
    await save.dir.rename('${save.dir.parent.path}/$newName');
    await _resetLocalSaveStorage();
    watcher.start();
  }

  Future<void> _eventHandlerWrapper(
    Future<void> Function(String) eventHandler,
    String path,
  ) async {
    watcher.togglePause();
    await eventHandler(path);
    watcher.togglePause();
  }

  Map<String, String> _getRawSaves() =>
      box.get('localSaves') as Map<String, String>;

  Future<void> _initBox() async {
    Hive.init(installationDirectoryPath);
    box = await Hive.openBox('se2savemanager');
    await _resetLocalSaveStorage();
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
}
