import 'package:watcher/watcher.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

const int MAX_SAVES = 2;

class SaveMeta {
  final int slot;
  final Directory parent;
  const SaveMeta({required this.slot, required this.parent});

  factory SaveMeta.fromJson(json) {
    return SaveMeta(slot: json['slot'], parent: Directory(json['parent']));
  }

  factory SaveMeta.fromDirectory(Directory dir) {
    final metaFile =
        (dir.listSync().firstWhere((e) => e.path.contains('.autobackup'))
                as File)
            .readAsStringSync();
    return SaveMeta.fromJson(jsonDecode(metaFile));
  }

  Map<String, dynamic> toJson() {
    return {"slot": slot, "parent": parent.path};
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

void copyDirectory({
  bool createMetaData = true,
  required Directory src,
  required Directory dst,
  required SaveMeta meta,
}) {
  print("Source: ${src.path}");
  print("Original destination: ${dst.path}");
  print("Parent path: ${meta.parent}");
  if (createMetaData) {
    final metaLoc = File("${dst.path}/.autobackup");
    metaLoc.createSync(recursive: true);
    final pp = JsonEncoder.withIndent(' ').convert(meta.toJson());
    metaLoc.writeAsStringSync(pp, mode: .write, flush: true);
  } else {
    dst = dst.parent.path.contains('.backups') ? dst.parent.parent : dst;
    File("${dst.path}/.tmp").createSync();
    final backup = Directory(
      '${dst.parent.parent.path}/.backup',
    ); //TODO: ZIP backup to avoid seeing it in loading screen, up one dir for now
    if (backup.existsSync()) {
      backup.deleteSync(recursive: true);
    }
    Process.runSync('robocopy', [dst.path, backup.path, '/E', '/B']);
    // dst.renameSync(backup.path);
    // dst.deleteSync(recursive: true);
  }
  print("Final destination: ${dst.path}");
  Process.runSync('robocopy', [src.path, dst.path, '/E', '/B']);
}

bool isBackup(Directory saveDir) {
  if (saveDir.path.contains('.backups')) {
    saveDir = saveDir.parent.parent;
  }
  return saveDir.listSync().any((c) => c.path.contains('.autobackup'));
}

bool isIgnored(Directory saveDir) {
  if (saveDir.path.contains('backups')) {
    saveDir = saveDir.parent.parent;
  }
  return saveDir.listSync().any((c) => c.path.contains('.tmp'));
}

File getContainerInfo(Directory dir) {
  final cFile = dir.listSync().firstWhere(
    (e) => e.path.contains('.container-info'),
  );
  return cFile as File;
}

Iterable<FileSystemEntity> getLikeSaves(
  //TODO:
  Directory rootSaveDir,
  String saveName,
) {
  return rootSaveDir.listSync().whereType<Directory>().where(
    (e) => saveName.contains(
      ContainerInfo.fromDirectory(e).value.containerMeta.displayName,
    ),
  );
}

void backupAndRenameSaves({
  required Directory rootSaveDir,
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
  final likeSaves = rootSaveDir.listSync().where(
    (e) => e.path.contains(saveName),
  ); // TODO: Yeah this doesn't work very well
  final existingSaves = <Directory>[];
  for (FileSystemEntity v in likeSaves) {
    v as Directory;
    isBackup(v) ? existingSaves.add(v) : {};
  }
  existingSaves.sort((a, b) {
    final fileA = getContainerInfo(a).lastModifiedSync();
    final fileB = getContainerInfo(b).lastModifiedSync();
    return fileA.compareTo(fileB);
  });
  if (existingSaves.length >= MAX_SAVES) {
    final lastSave = existingSaves.last;
    print("Deleting oldest save: ${lastSave.path}");
    lastSave.deleteSync(recursive: true);
    existingSaves.removeLast();
  }
  ;
  for (FileSystemEntity e in existingSaves) {
    final dir = Directory(e.path);
    final slot = SaveMeta.fromDirectory(dir).slot + 1;
    final meta = SaveMeta(slot: slot, parent: saveDir);
    ContainerInfo container = ContainerInfo.fromDirectory(dir);
    String name = container.value.containerMeta.displayName;
    String newName = '${name.substring(0, name.lastIndexOf('_'))}_$slot';
    Directory dst = Directory("$saveLoc/$newName");
    bool createMeta = true;
    Directory parent = meta.parent;
    print(saveDir.path);
    print(isBackup(saveDir));
    if (meta.parent.existsSync() && isBackup(saveDir)) {
      print("backup trying to save");
      if (meta.parent.path.contains('.backups')) {
        parent = SaveMeta.fromDirectory(
          meta.parent.parent.parent,
        ).parent; // TODO: add meta trueParent property
        container = ContainerInfo.fromDirectory(meta.parent.parent.parent);
        print("Container location: ${meta.parent.parent.parent}");
        newName = container.value.containerMeta.displayName;
      }
      final containerParent = ContainerInfo.fromDirectory(dst);
      dst = parent;
      createMeta = false;
    }
    copyDirectory(src: dir, dst: dst, meta: meta, createMetaData: createMeta);
    modifyContainerInfo(dst, container, newName);
  }
  final backupSaveDir = Directory("$saveLoc/${saveName}_2");
  backupSaveDir.createSync(recursive: true);
  final meta = SaveMeta(slot: 2, parent: saveDir);
  copyDirectory(
    src: saveDir,
    dst: backupSaveDir,
    meta: meta,
  ); // starting slot at 2 means I don't have to parse display names
  modifyContainerInfo(backupSaveDir, containerInfo, '${saveName}_2');
}

void modifyContainerInfo(Directory dir, ContainerInfo container, String name) {
  print(
    "Modifying container: ${dir.path} with $name from ${container.value.containerMeta.displayName}",
  );
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
    final rootSaveDir = Directory(saveLoc);
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
        if (isIgnored(newSaveDir)) {
          Directory tmpSaveDir = newSaveDir;
          if (tmpSaveDir.path.contains('.backups'))
            tmpSaveDir = tmpSaveDir.parent.parent;
          final tmp = File("${tmpSaveDir.path}/.tmp");
          final metaFile = File("${tmpSaveDir.path}/.autobackup");
          if (tmp.existsSync()) {
            tmp.deleteSync();
            if (metaFile.existsSync()) metaFile.deleteSync();
          } else {
            print("unable to find .tmp file...: ${tmp.path}");
          }
        } else {
          backupAndRenameSaves(
            rootSaveDir: rootSaveDir,
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
