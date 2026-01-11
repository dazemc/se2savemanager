import 'dart:io';

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

  void install() async {
    if (installationDirectoryPath.isNotEmpty) {
      final dir = Directory(installationDirectoryPath);
      if (await dir.exists()) {
        print('se2savemanger already installed');
        //TODO: give option to uninstall/reinstall
        return;
      }
      await dir.create();
      if (!await dir.exists()) {
        throw 'Could not create se2savemanager directory at location: $dir';
      }
    }
  }
}
