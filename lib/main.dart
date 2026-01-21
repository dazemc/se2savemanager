import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/views/save_app.dart';

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
