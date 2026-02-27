import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive_ce.dart';
import 'package:logging/logging.dart';
import 'package:se2savemanager/hive/hive_registrar.g.dart';
import 'package:se2savemanager/models/managed_save.dart';
import 'package:se2savemanager/models/save.dart';
import 'package:se2savemanager/services/save_watcher.dart';

import 'save_logger.dart';

class SaveManager {
  //TODO: Linux
  final bool useTimeStamp = false; //TODO
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
    //TODO: check for missing slots, ie name, name 3, name 4 => next save would be name 2 != name 4
    await watcher.stop();
    await _checkManagedSaves();
    // assert(!watcher.isRunning);
    final name = save.container.value.containerMeta.displayName;
    String path = save.dir.path;
    _log.severe("CHECK: $path");
    _log.info(save.container.value.containerMeta.toString());
    final ManagedSave managedSave =
        saveBox.get(path) ??
        ManagedSave(name: name, path: path, children: {}, isParent: true);
    _log.warning('SAVE_CHECK: ${managedSave.toMap()}');
    final children = managedSave.children.keys;
    _log.warning('CHILDREN: $children');
    final count = children.isNotEmpty ? children.length + 2 : 2;
    if (path.contains('.backups')) {
      _log.info('Working with .backup save: $path');
      managedSave.isParent = false;
      path = path.substring(0, path.indexOf('.backups'));
      _log.info('New path will be: $path');
    }
    final newPath = '$path $count';
    _log.info('Copying from: ${managedSave.path}\nto: $newPath');
    if (managedSave.path.contains('backups')) {
      final backupParent = Directory(managedSave.path).parent.parent.path;
      _log.warning('.backups detected, using parent instead: $backupParent');
      await _copyPath(backupParent, newPath);
    } else {
      await _copyPath(managedSave.path, newPath);
      _log.severe(managedSave.path);
    }
    final newSave = await Save.fromPath(newPath);
    final newName = '$name $count';
    final now = DateTime.now();
    final timeStamp = '$name $now';
    newSave.container.value.containerMeta.displayName = useTimeStamp
        ? timeStamp
        : newName;
    await _writeContainer(newSave, newPath, newName);
    _log.info('Copying save: $name at $path');
    _log.info('Storing save: ${managedSave.toMap()}');
    managedSave.children['$name $count'] = newPath;
    saveBox.put(path, managedSave);
    await _resetLocalSaveStorage();
    watcher.start();
  }

  Future<void> deleteSave(Save save) async {
    await watcher.stop();
    assert(!watcher.isRunning);
    if (await save.dir.exists()) {
      await save.dir.delete(recursive: true);
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
    // assert(!watcher.isRunning);
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

  Future<void> _checkManagedSaves() async {
    for (String name in saveBox.keys.toList()) {
      final ManagedSave save = saveBox.get(name);
      _log.warning(save.path);
      final dir = Directory(save.path);
      if (!await dir.exists()) {
        _log.warning('Save no longer exists: removing $name');
        saveBox.delete(name);
      } else {
        for (MapEntry child in save.children.entries.toList()) {
          final path = child.value;
          final childDir = Directory(path);
          if (!await childDir.exists()) {
            _log.warning('Child save no longer exists: removing ${child.key}');
            save.children.remove(child.key);
            _log.warning(save.children);
          }
          saveBox.put(name, save);
        }
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
      if (file.path.contains('backups')) {
        continue;
      }
      final relativePath = file.path.substring(from.length + 1);
      final destinationPath = '$to/$relativePath';

      if (file is Directory) {
        // _log.info('Copying directory: ${file.path}');
        await Directory(destinationPath).create(recursive: true);
      } else if (file is File) {
        // _log.info('Copying file: ${file.path}');
        final destFile = File(destinationPath);
        // _log.info('Destination: $destinationPath');
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
    await watcher.stop();
    await Future.delayed(.new(seconds: 1)); // wait for game to finish writing
    _log.warning('NEW SAVE: $path');
    final dir = (path.contains('.backups'))
        ? File(path).parent.parent.parent
        : File(path).parent;
    final save = await Save.fromDirectory(dir);
    await copySave(save);
    await eventHandler(path);
    watcher.start();
  }

  Map<String, String> _getRawSaves() =>
      box.get('localSaves') as Map<String, String>;

  Future<void> _initBox() async {
    Hive
      ..init(installationDirectoryPath)
      ..registerAdapters();
    box = await Hive.openBox('se2savemanager');
    saveBox = await Hive.openBox('managedSaves');
    await _checkManagedSaves();
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
}
