import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/services/save_manager.dart';
import 'package:system_theme/system_theme.dart';

// Future<void> main() async {
//   final log = SaveLogger(name: pid.toString()).log;
//   final saveManager = SaveManager();
//   await saveManager.init();
//   saveManager.box.put('name', 'test');
//   final dynamic name = saveManager.box.get('name');
//   assert(name is String);
//   log.info(name);
//   saveManager.watcher.start();
//   log.info('Non-blocking test');
// }

void main() {
  runApp(const SaveApp());
  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class SaveApp extends StatelessWidget {
  const SaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: "Space Engineers 2 Save Manager",
      theme: .new(
        brightness: .dark,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
      ),
      debugShowCheckedModeBanner: false,
      home: ScaffoldPage(
        content: Row(mainAxisAlignment: .center, children: [Text('test')]),
      ),
    );
  }
}
