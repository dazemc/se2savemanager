import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'logo.dart';

class _WindowButtons extends StatelessWidget {
  const _WindowButtons();
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

class SaveAppTitleBar extends StatelessWidget {
  const SaveAppTitleBar({super.key});
  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Logo(padding: .only(top: 8, bottom: 4), height: 50, width: 50),
          Expanded(child: MoveWindow()),
          _WindowButtons(),
        ],
      ),
    );
  }
}
