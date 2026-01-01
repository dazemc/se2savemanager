import 'package:watcher/watcher.dart';
import 'dart:io';
import 'dart:async';

const int MAX_SAVES = 4;

void copyDirectory(Directory src, Directory dst) {
  Process.runSync('robocopy', [src.path, dst.path, '/E', '/B']);
  File("${dst.path}/.autobackup").createSync();
}

void startWatcher() {
  final appDataDir = Platform.environment['APPDATA'];
  final saveLoc = "$appDataDir/SpaceEngineers2/AppData/SaveGames";
  final watcher = DirectoryWatcher(saveLoc);
  int deleteCount = 0;
  StreamSubscription? sub;

  sub = watcher.events.listen((event) {
    final saveDir = Directory(saveLoc).listSync();
    final saveContentDirs = saveDir.where((e) => e is Directory).toList();
    if (event.type.toString() != 'remove') {
      bool isBackup = false;
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
      newSaveDir.listSync().where((e) => e is File).forEach((c) {
        if (c.path.contains('.autobackup')) {
          isBackup = true;
        }
      });
      if (newSaveDir.parent.path == saveLoc && !isBackup) {
        // final count = existingSaves.length;
        final saveList = existingSaves.toList();
        saveList.reversed.forEach((e) {
          if (e.path.contains('_')) {
            final slot = int.parse(
              e.path.substring(e.path.lastIndexOf('_') + 1),
            );
            final name = "$saveLoc/${newSaveName}_";
            e.renameSync("$name${slot + 1}");
            if (slot + 1 > MAX_SAVES) {
              Directory("$name${slot + 1}").deleteSync(recursive: true);
            }
          }
        });
        final backupSaveDir = Directory("$saveLoc/${newSaveName}_2");
        copyDirectory(newSaveDir, backupSaveDir);
        sub?.cancel();
        Future.delayed(Duration(seconds: 1), startWatcher);
      }
    }
  });
}

void main() async {
  startWatcher();
  // Completer<void>().future;
}
