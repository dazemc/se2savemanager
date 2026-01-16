import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/widgets/logo.dart';
import 'package:se2savemanager/widgets/titlebar.dart';
import 'package:system_theme/system_theme.dart';

import 'save_app_content.dart';

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
        content: Column(children: [SaveAppTitleBar(), SaveAppContent()]),
      ),
    );
  }
}
