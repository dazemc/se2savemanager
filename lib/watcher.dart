import 'package:watcher/watcher.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

// {
//   "$Bundles": {
//     "System.Runtime": "1.0.0.0",
//     "VRage": "2.0.2.51"
//   },
//   "$Type": "VRage:Keen.VRage.Library.Filesystem.StorageManagers.ContainerInfo`1<VRage:Keen.VRage.Core.Worlds.WorldSessionSaveGameMetaData>",
//   "$Value": {
//     "Meta": {
//       "BaseMetadata": null,
//       "DisplayName": "again",
//       "Description": "",
//       "GameVersion": 2000002,
//       "GameBuildNumber": 51,
//       "SaveGameCreationTimeInTicks": 639029565634567089,
//       "PCU": 200284,
//       "UsedDebugMenu": false
//     },
//     "AdditionalData": {}
//   }
// }
class ContainerInfo {
  final ContainerBundles bundles;
  final String type;
  final ContainerValue value;
  const ContainerInfo({
    required this.bundles,
    required this.type,
    required this.value,
  });

  factory ContainerInfo.fromJson(Map<String, dynamic> json) {
    return ContainerInfo(
      type: json[r'$Type'] as String,
      bundles: ContainerBundles.fromJson(json[r'$Bundles']),
      value: ContainerValue.fromJson(json[r'$Value']),
    );
  }
}

class ContainerBundles {
  final String systemRuntime;
  final String vRage;
  const ContainerBundles({required this.systemRuntime, required this.vRage});

  factory ContainerBundles.fromJson(Map<String, dynamic> json) {
    return ContainerBundles(
      systemRuntime: json['System.Runtime'] as String,
      vRage: json['VRage'] as String,
    );
  }
}

class ContainerValue {
  final ContainerMeta containerMeta;
  final Map additonalData;
  const ContainerValue({
    required this.containerMeta,
    required this.additonalData,
  });

  factory ContainerValue.fromJson(Map<String, dynamic> json) {
    return ContainerValue(
      additonalData: {}, // TODO: currently empty in my game
      containerMeta: ContainerMeta.fromJson(json['Meta']),
    );
  }
}

class ContainerMeta {
  final String? baseMetadata;
  final String displayName;
  final String description;
  final int gameVersion;
  final int gameBuildNumber;
  final int saveCreationTimeInTicks;
  final int pcu;
  final bool usedDebugMenu;
  const ContainerMeta({
    this.baseMetadata,
    required this.displayName,
    required this.description,
    required this.gameVersion,
    required this.gameBuildNumber,
    required this.saveCreationTimeInTicks,
    required this.pcu,
    required this.usedDebugMenu,
  });

  factory ContainerMeta.fromJson(Map<String, dynamic> json) {
    return ContainerMeta(
      baseMetadata: json['BaseMetadata'] as String?,
      displayName: json['DisplayName'] as String,
      description: json['Description'] as String,
      gameVersion: json['GameVersion'] as int,
      gameBuildNumber: json['GameBuildNumber'] as int,
      saveCreationTimeInTicks: json['SaveGameCreationTimeInTicks'] as int,
      pcu: json['PCU'] as int,
      usedDebugMenu: json['UsedDebugMenu'] as bool,
    );
  }
}

const int MAX_SAVES = 4;

void copyDirectory(Directory src, Directory dst) {
  Process.runSync('robocopy', [src.path, dst.path, '/E', '/B']);
  File("${dst.path}/.autobackup").createSync();
}

bool isAuto(Directory saveDir) {
  bool isBackup = false;
  saveDir.listSync().whereType<File>().forEach(
    (c) => c.path.contains('.autobackup') ? isBackup = true : {},
  );
  return isBackup;
}

void backupAndRenameSavesDirs(
  List<FileSystemEntity> saveContentDirs,
  Directory saveDir,
  String saveLoc,
  String saveName,
  bool isBackup,
) {
  final existingSaves = saveContentDirs.where((e) => e.path.contains(saveName));

  if (saveDir.parent.path == saveLoc && !isBackup) {
    final saveList = existingSaves.toList();
    for (FileSystemEntity e in saveList.reversed) {
      if (e.path.contains('_')) {
        final slot = int.parse(e.path.substring(e.path.lastIndexOf('_') + 1));
        final name = "$saveLoc/${saveName}_";
        e.renameSync("$name${slot + 1}");
        if (slot + 1 > MAX_SAVES) {
          Directory("$name${slot + 1}").deleteSync(recursive: true);
        }
      }
    }
    final backupSaveDir = Directory("$saveLoc/${saveName}_2");
    copyDirectory(saveDir, backupSaveDir);
  }
}

void restartWatcher(StreamSubscription? sub) {
  sub?.cancel();
  Future.delayed(Duration(seconds: 1), startWatcher);
}

// void getContainerInfos(Directory appDataDir) {
//   final appDataDirs = appDataDir.listSync().whereType<Directory>();
//   List<File> containerInfos = <File>[];
//   for (Directory dir in appDataDirs) {
//     final dirList = dir.listSync();
//     final files = dirList.whereType<File>();
//     final backups = dirList.where((e) => e.path.contains('.backups'));
//     if (backups.length > 0) {
//       final backupsDirs = (backups as Directory)
//           .listSync()
//           .whereType<Directory>();
//       for (Directory backDir in backupsDirs) {
//         final backupFiles = backDir.listSync().whereType<File>();
//       }
//     }
//   }
// }
//
void startWatcher() {
  final appDataDir = Platform.environment['APPDATA'];
  final saveLoc = "$appDataDir/SpaceEngineers2/AppData/SaveGames";
  final watcher = DirectoryWatcher(saveLoc);

  StreamSubscription? sub;

  sub = watcher.events.listen((event) {
    final saveDir = Directory(saveLoc).listSync();
    final saveContentDirs = saveDir.whereType<Directory>().toList();
    if (event.type.toString() != 'remove') {
      final newSaveRawPath = event.path;
      if (newSaveRawPath.contains('.container-info')) {
        final containerInfo = File(newSaveRawPath);
        // print(containterInfo.lastModifiedSync());
        sleep(.new(milliseconds: 200));
        final containerInfoContents = containerInfo.readAsStringSync();
        final containerJson = jsonDecode(containerInfoContents);
        assert(containerJson is Map);
        final container = ContainerInfo.fromJson(containerJson);
        print(container.value.containerMeta.displayName);
        restartWatcher(sub);
      }
      final newSavePath = newSaveRawPath.substring(
        0,
        newSaveRawPath.lastIndexOf('\\'),
      );
      final newSaveDir = Directory(newSavePath);
      final newSaveName = newSavePath.substring(
        newSavePath.lastIndexOf('\\') + 1,
      );
      final isBackup = isAuto(newSaveDir);
      backupAndRenameSavesDirs(
        saveContentDirs,
        newSaveDir,
        saveLoc,
        newSaveName,
        isBackup,
      );
      // restartWatcher(sub);
    }
  });
}

void main() async {
  startWatcher();
  // Completer<void>().future;
}
