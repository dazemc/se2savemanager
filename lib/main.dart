import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    appWindow.alignment = .center;
    appWindow.title = 'Space Engineers 2 Save Manager';
    appWindow.show();
  });
}

class Logo extends StatelessWidget {
  const Logo({super.key});
  static final String logoName = 'assets/images/se2.svg';
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      logoName,
      semanticsLabel: 'SE2 Logo',
      width: 25,
      height: 25,
    );
  }
}

class SaveApp extends StatelessWidget {
  const SaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Space Engineers 2 Save Manager',
      theme: .new(
        brightness: .dark,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
      ),
      debugShowCheckedModeBanner: false,
      home: ScaffoldPage(
        padding: .only(top: 0),
        content: Column(
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [
                  Logo(),
                  Expanded(child: MoveWindow()),
                  WindowButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton(),
      ],
    );
  }
}
