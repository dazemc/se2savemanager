import 'package:watcher/watcher.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

//TODO: detect child save and then overwrite parent with that child
// i.e, you load save_3, when you save it should not be save_3_2, it should move current parent to save_2 and save as the new parent save.
// I'm thinking I'll do what I did with that mermaid port and hash the save, keep a map in the root of the save dir to track managed saves
class SaveMeta {
  final int slot;
  final String parent;
  const SaveMeta({required this.slot, required this.parent});

  factory SaveMeta.fromJson(json) {
    return SaveMeta(slot: json['slot'], parent: json['parent']);
  }

  factory SaveMeta.fromDirectory(Directory dir) {
    final metaFile =
        (dir.listSync().firstWhere((e) => e.path.contains('.autobackup'))
                as File)
            .readAsStringSync();
    return SaveMeta.fromJson(jsonDecode(metaFile));
  }

  Map<String, dynamic> toJson() {
    return {"slot": slot, "parent": parent};
  }
}

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

  factory ContainerInfo.fromDirectory(Directory dir) {
    final json = jsonDecode(getContainerInfo(dir).readAsStringSync());
    return ContainerInfo.fromJson(json);
  }

  Map<String, dynamic> toJson() => {
    r'$Bundles': bundles.toJson(),
    r'$Type': type,
    r'$Value': value.toJson(),
  };
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
  Map<String, dynamic> toJson() => {
    'System.Runtime': systemRuntime,
    'VRage': vRage,
  };
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
  Map<String, dynamic> toJson() => {
    'Meta': containerMeta.toJson(),
    'AdditionalData': additonalData,
  };
}

class ContainerMeta {
  final String? baseMetadata;
  String displayName;
  final String description;
  final int gameVersion;
  final int gameBuildNumber;
  final int saveCreationTimeInTicks;
  final int pcu;
  final bool usedDebugMenu;
  ContainerMeta({
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

  Map<String, dynamic> toJson() => {
    'BaseMetadata': baseMetadata,
    'DisplayName': displayName,
    'Description': description,
    "GameVersion": gameVersion,
    "GameBuildNumber": gameBuildNumber,
    "SaveGameCreationTimeInTicks": saveCreationTimeInTicks,
    "PCU": pcu,
    "UsedDebugMenu": usedDebugMenu,
  };
}

const int MAX_SAVES = 4;

void copyDirectory({
  required Directory src,
  required Directory dst,
  required SaveMeta meta,
}) {
  Process.runSync('robocopy', [src.path, dst.path, '/E', '/B']);
  final metaLoc = File("${dst.path}/.autobackup");
  metaLoc.createSync();
  final pp = JsonEncoder.withIndent(' ').convert(meta.toJson());
  metaLoc.writeAsStringSync(pp);
}

bool isAuto(Directory saveDir) {
  bool isBackup = false;
  saveDir.listSync().whereType<File>().forEach(
    (c) => c.path.contains('.autobackup') ? isBackup = true : {},
  );
  return isBackup;
}

File getContainerInfo(Directory dir) {
  final cFile = dir.listSync().firstWhere(
    (e) => e.path.contains('.container-info'),
  );
  return cFile as File;
}

void backupAndRenameSaves({
  required List<FileSystemEntity> saveContentDirs,
  required Directory saveDir,
  required String saveLoc,
  required String saveName,
  required ContainerInfo containerInfo,
}) {
  /*
  get a list of all the dirs that have the name of the save and have a .autobackup file
  TODO: need more robust way to handle parent/children association 
  then rename both the .container-info display name and dir after incrementing .autobackup
  finally create the most recent save by taking a backup of the original
  this keeps the _2 save the most recent at all times and allows the oldest to pop off when MAX_SAVES is hit
  */
  final likeSaves = saveContentDirs.where((e) => e.path.contains(saveName));
  final existingSaves = <Directory>[];
  for (FileSystemEntity v in likeSaves) {
    v as Directory;
    isAuto(v) ? existingSaves.add(v) : {};
  }
  List<Directory> saveList = existingSaves.toList();
  saveList.sort((a, b) {
    final fileA = getContainerInfo(a).lastModifiedSync();
    final fileB = getContainerInfo(b).lastModifiedSync();
    return fileA.compareTo(fileB);
  });
  if (saveList.length > MAX_SAVES) saveList.first.deleteSync();
  for (FileSystemEntity e in saveList) {
    final dir = Directory(e.path);
    final slot = SaveMeta.fromDirectory(dir).slot;
    final meta = SaveMeta(slot: slot, parent: saveDir.path);
    final container = ContainerInfo.fromDirectory(dir);
    final name = container.value.containerMeta.displayName;
    final newName = '${name.substring(0, name.lastIndexOf('_'))}_$slot';
    final dst = Directory("$saveLoc/$newName");
    copyDirectory(src: dir, dst: dst, meta: meta);
    modifyContainerInfo(dst, container, '$newName');
  }
  final backupSaveDir = Directory("$saveLoc/${saveName}_2");
  backupSaveDir.createSync(recursive: true);
  final meta = SaveMeta(slot: 2, parent: saveDir.path);
  copyDirectory(
    src: saveDir,
    dst: backupSaveDir,
    meta: meta,
  ); // starting slot at 2 means I don't have to parse display names
  modifyContainerInfo(backupSaveDir, containerInfo, '${saveName}_2');
}

void modifyContainerInfo(Directory dir, ContainerInfo container, String name) {
  sleep(.new(milliseconds: 200));
  container.value.containerMeta.displayName = name;
  final file = File('${dir.path}/.container-info');
  JsonEncoder encoder = .withIndent('  ');
  final prettyPrint = encoder.convert(container.toJson());
  file.writeAsStringSync(prettyPrint, mode: .write, flush: true);
}

void restartWatcher(StreamSubscription? sub) {
  sub?.cancel();
  Future.delayed(Duration(seconds: 1), startWatcher);
}

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
        sleep(.new(milliseconds: 200)); // wait for the game to finish writing
        final containerInfoContents = containerInfo.readAsStringSync();
        final containerJson = jsonDecode(containerInfoContents);
        assert(containerJson is Map);
        final container = ContainerInfo.fromJson(containerJson);

        final newSavePath = newSaveRawPath.substring(
          0,
          newSaveRawPath.lastIndexOf('\\'),
        );
        final newSaveDir = Directory(newSavePath);
        final isBackup = isAuto(newSaveDir);
        if (!isBackup) {
          backupAndRenameSaves(
            saveContentDirs: saveContentDirs,
            saveDir: newSaveDir,
            saveLoc: saveLoc,
            saveName: container.value.containerMeta.displayName,
            containerInfo: container,
          );
        }
        restartWatcher(sub);
      }
    }
  });
}

void main() async {
  startWatcher();
}
