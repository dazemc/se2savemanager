import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
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
