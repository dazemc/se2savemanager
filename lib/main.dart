import 'dart:io';

import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/services/save_manager.dart';

Future<void> main() async {
  final log = SaveLogger(name: pid.toString()).log;
  final saveManager = SaveManager();
  await saveManager.init();
  saveManager.box.put('name', 'test');
  final dynamic name = saveManager.box.get('name');
  assert(name is String);
  log.info(name);
  saveManager.watcher.start();
  log.info('Non-blocking test');
}
