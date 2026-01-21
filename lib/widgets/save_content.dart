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
      final meta = save.container.value.containerMeta;
      final screenshot = Image.memory(save.screenshot!);
      final name = meta.displayName;
      final gameVersion = meta.gameVersion;
      final pcu = meta.pcu;
      final ticks = meta.saveCreationTimeInTicks;
      return ListTile.selectable(
        leading: SizedBox(
          height: 100,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            //TODO: screenshot
            child: screenshot,
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
