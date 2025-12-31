import 'package:watcher/watcher.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shell/shell.dart';

Future<void> copyDirectory(Directory src, Directory dst) async {
  await dst.create(recursive: true);
  await for (final entity in src.list()) {
    final newPath = p.join(dst.path, p.basename(entity.path));
    if (entity is Directory) {
      await copyDirectory(entity, Directory(newPath));
    } else if (entity is File) {
      await entity.copy(newPath);
    }
    File("${dst.path}/.autobackup").create();
  }
}

void main() async {
  final appDataDir = Platform.environment['APPDATA'];
  final saveLoc = "$appDataDir/SpaceEngineers2/AppData/SaveGames";
  final watcher = DirectoryWatcher(saveLoc);
  watcher.events.listen((event) async {
    final saveDir = Directory(saveLoc).list();
    final saveContentDirs = await saveDir.where((e) => e is Directory).toList();
    if (event.type.toString() != 'remove') {
      final newSaveRawPath = event.path;
      final newSavePath = newSaveRawPath.substring(
        0,
        newSaveRawPath.lastIndexOf('\\'),
      );
      final newSaveDir = Directory(newSavePath);
      final newSaveName = newSavePath.substring(
        newSavePath.lastIndexOf('\\') + 1,
      );
      final existingSaves = saveContentDirs.where(
        (e) => e.path.contains(newSaveName),
      );
      final backupSaveDir = Directory(
        "$saveLoc/${newSaveName}_${existingSaves.length + 1}",
      );
      bool isBackup = false;
      await newSaveDir.list().where((e) => e is File).forEach((c) {
        if (c.path.contains('.autobackup')) {
          isBackup = true;
        }
      });
      if (!isBackup) {
        copyDirectory(newSaveDir, backupSaveDir);
      }
    }
  });
}
