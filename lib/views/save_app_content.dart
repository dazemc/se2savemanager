import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se2savemanager/bloc/save_bloc.dart';

class SaveAppContent extends StatelessWidget {
  const SaveAppContent({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveBloc, SaveState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
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
      },
    );
  }
}
