import 'package:hive_ce/hive_ce.dart';
import 'package:se2savemanager/services/save_manager.dart';

Future<void> main() async {
  final saveManager = SaveManager();
  await saveManager.init();
  saveManager.box.put('name', 'test');
  final dynamic name = saveManager.box.get('name');
  assert(name is String);
  print(name);
  saveManager.watcher.start();
  print('Non-blocking test');
}
