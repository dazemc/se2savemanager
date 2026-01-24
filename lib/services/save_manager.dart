import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive_ce.dart';
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
  late final Box saveBox;

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
    final boxSave = saveBox.get(name, defaultValue: {});
    late ManagedSave managedSave;
    if (boxSave.isEmpty) {
      _log.info('Copying unmanaged save');
      managedSave = ManagedSave(
        name: name,
        path: path,
        children: {},
        isParent: true,
      );
    } else {
      managedSave = ManagedSave.fromMap(boxSave);
      _log.info('Save is managed: ${managedSave.toMap()}');
    }
    final children = managedSave.children.keys;
    final count = children.isNotEmpty ? children.length + 2 : 2;
    final newPath = '$path $count';
    _log.info('New path: $newPath');
    await _copyPath(path, newPath);
    final newSave = await Save.fromPath(newPath);
    newSave.container.value.containerMeta.displayName = '$name $count';
    //TODO after making a managed save
    // managedSave.children['$name $count'] = newPath;
    _log.info('Copying save: $name at $path');
  }

  Future<void> deleteSave(Save save) async {
    watcher.stop();
    if (await save.dir.exists()) {
      save.dir.delete(recursive: true);
      await _resetLocalSaveStorage();
    }
    watcher.start();
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
    final newSave = await Save.fromPath(path!);
    _log.info('Renaming save at: $path');
    newSave.container.value.containerMeta.displayName = newName;
    await _writeContainer(newSave, path, newName);

    for (int i = 0; i < 10; i++) {
      if (newSave.container.value.containerMeta.displayName == newName) {
        break;
      }
      try {
        await newSave.dir.rename('${newSave.dir.parent.path}/$newName');
        break;
      } on FileSystemException catch (_) {
        await Future.delayed(const Duration(milliseconds: 50));
        _log.warning('Waiting for filesystem to be free...');
      }
    }
    await _resetLocalSaveStorage();
    watcher.start();
  }

  Future<void> _writeContainer(Save save, String path, String newName) async {
    JsonEncoder encoder = .withIndent(r'  ');
    final prettyPrint = encoder.convert(save.container.toJson());
    await File(
      '$path/.container-info',
    ).writeAsString(prettyPrint, mode: .write, flush: true);
    for (int i = 0; i < 10; i++) {
      try {
        await save.dir.rename('${save.dir.parent.path}/$newName');
        break;
      } on FileSystemException catch (_) {
        await Future.delayed(const Duration(milliseconds: 50));
        _log.warning('Waiting for filesystem to be free...');
      }
    }
  }

  Future<void> _copyPath(
    String from,
    String to, {
    bool overwrite = false,
  }) async {
    final fromDir = Directory(from);
    final toDir = Directory(to);

    await toDir.create(recursive: true);

    await for (final file in fromDir.list(recursive: true)) {
      if (file.path.contains('.backups')) {
        _log.info('Skipping: ${file.path}');
        continue;
      }

      final relativePath = file.path.substring(from.length + 1);
      final destinationPath = '$to/$relativePath';

      if (file is Directory) {
        await Directory(destinationPath).create(recursive: true);
      } else if (file is File) {
        final destFile = File(destinationPath);
        if (overwrite) {
          if (await destFile.exists()) {
            await destFile.delete();
          }
        }

        await file.copy(destinationPath);
      }
    }
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
    saveBox = await Hive.openBox('managedSaves');
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

  //   Future<void> _resetLocalSaveStorage() async {
  //     Map<String, String> saves = {};
  //     await for (FileSystemEntity e in _spaceEngineersSaveDirectory.list()) {
  //       if (await File('${e.path}/.container-info').exists() && e is Directory) {
  //         final save = await Save.fromDirectory(e);
  //         saves[save.container.value.containerMeta.displayName] = e.path;
  //       }
  //     }
  //     box.put('localSaves', saves);
  //   }
  // }

  Future<void> _resetLocalSaveStorage() async {
    Map<String, String> saves = {};

    if (!await _spaceEngineersSaveDirectory.exists()) {
      _log.warning(
        'Save directory does not exist: ${_spaceEngineersSaveDirectory.path}',
      );
      box.put('localSaves', saves);
      return;
    }

    await for (final e in _spaceEngineersSaveDirectory.list()) {
      try {
        if (e is Directory &&
            await File('${e.path}/.container-info').exists()) {
          final save = await Save.fromDirectory(e);
          saves[save.container.value.containerMeta.displayName] = e.path;
        }
      } on PathNotFoundException catch (_) {
        _log.warning('Skipping missing save directory: ${e.path}');
        continue;
      } on FileSystemException catch (_) {
        _log.warning('Skipping inaccessible save directory: ${e.path}');
        continue;
      }
    }

    box.put('localSaves', saves);
  }
}
