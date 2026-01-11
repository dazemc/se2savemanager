import 'package:hive_ce/hive_ce.dart';
import 'package:se2savemanager/models/save_manager.dart';
import 'package:se2savemanager/services/save_watcher.dart';

void main() async {
  Hive.init('se2savemanager');
  final Box box = await Hive.openBox('.');
  box.put('name', 'test');
  final dynamic name = box.get('name');
  assert(name is String);
  print(name);
  final saveManger = SaveManager();
  final watcher = SaveWatcher(
    watchPath: saveManger.spaceEngineersSaveDirectoryPath,
    onChange: (path) => print(path),
  ).start();
  print('Non-blocking test');
}
