import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SaveAppContent extends StatelessWidget {
  const SaveAppContent({super.key});
  @override
  Widget build(BuildContext context) {
    print(appWindow.size.height);
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: .new(
            image: AssetImage('assets/images/skybox.jpg'),
            fit: .cover,
          ),
        ),
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) {
            return ListTile.selectable(
              leading: SizedBox(
                height: 100,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ColoredBox(
                    color: Colors.accentColors[index ~/ 20],
                    child: const Placeholder(),
                  ),
                ),
              ),
              title: Text('TestTitle'),
              subtitle: const Text('Text subtitle'),
              selectionMode: .single,
              // selected: , //TODO:
              // onSelectionChange: (v) => bloc, //TODO:
            );
          },
        ),
      ),
    );
  }
}
