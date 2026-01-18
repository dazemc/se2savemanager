import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/bloc/app/app_bloc.dart';

class SaveContent extends StatelessWidget {
  final AppState state;
  const SaveContent({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return _determineSaveContent(state);
  }
}

Widget _determineSaveContent(AppState state) {
  return state is AppBusy
      ? Center(child: SizedBox(height: 69, width: 69, child: ProgressRing()))
      : _saveContent();
}

ListView _saveContent() {
  return ListView.builder(
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
  );
}
