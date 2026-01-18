import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/bloc/app/app_bloc.dart';
import 'package:se2savemanager/models/save.dart';

class SaveContent extends StatelessWidget {
  final AppState state;
  const SaveContent({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return _determineSaveContent(state);
  }
}

Widget _determineSaveContent(AppState state) {
  return state is AppReady
      ? _saveContent(state.saves)
      : Center(child: SizedBox(height: 69, width: 69, child: ProgressRing()));
}

ListView _saveContent(List<Save> saves) {
  return ListView.builder(
    itemCount: saves.length,
    itemBuilder: (context, index) {
      final save = saves[index];
      final name = save.container.value.containerMeta.displayName;
      final gameVersion = save.container.value.containerMeta.gameVersion;
      final pcu = save.container.value.containerMeta.pcu;
      final ticks = save.container.value.containerMeta.saveCreationTimeInTicks;
      return ListTile.selectable(
        leading: SizedBox(
          height: 100,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            //TODO: screenshot
            child: ColoredBox(
              color: Colors.accentColors[index ~/ 20],
              child: const Placeholder(),
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text('PCU: $pcu\nGame Version: $gameVersion\nTicks: $ticks'),
        selectionMode: .single,
        // selected: , //TODO:
        // onSelectionChange: (v) => bloc, //TODO:
      );
    },
  );
}
