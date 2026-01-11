import 'dart:io';
import 'package:hive_ce/hive_ce.dart';
import 'package:se2savemanager/services/save_watcher.dart';

class SaveManager {
  //TODO: Linux
  final String installationDirectoryPath;
  final String spaceEngineersSaveDirectoryPath;
  SaveManager()
    : installationDirectoryPath = Platform.isWindows
          ? '${Platform.environment["APPDATA"]!}/se2savemanager'
          : '',
      spaceEngineersSaveDirectoryPath = Platform.isWindows
          ? '${Platform.environment["APPDATA"]!}/SpaceEngineers2/AppData/SaveGames'
          : '';

  late final Box box;
  late final SaveWatcher watcher;

  Future<void> _install() async {
    if (installationDirectoryPath.isNotEmpty) {
      final dir = Directory(installationDirectoryPath);
      if (await dir.exists()) {
        print('se2savemanger already installed');
        //TODO: give option to uninstall/reinstall
        return;
      } else {
        await dir.create();
      }
      if (!await dir.exists()) {
        throw 'Could not create se2savemanager directory at location: $dir';
      }
    }
  }

  Future<void> init() async {
    await _install();
    Hive.init(installationDirectoryPath);
    box = await Hive.openBox('se2savemanager');
    watcher = SaveWatcher(
      watchPath: spaceEngineersSaveDirectoryPath,
      onChange: (path) => print(path),
    );
  }
}
