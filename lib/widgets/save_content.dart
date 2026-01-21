import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/bloc/app/app_bloc.dart';
import 'package:se2savemanager/bloc/manager/manager_bloc.dart';
import 'package:se2savemanager/main.dart';

class SaveContent extends StatelessWidget {
  final AppState state;
  final AppBloc appBloc;
  final ManagerBloc managerBloc;
  const SaveContent({
    super.key,
    required this.state,
    required this.appBloc,
    required this.managerBloc,
  });
  @override
  Widget build(BuildContext context) {
    return _determineSaveContent(state, appBloc, managerBloc);
  }
}

Widget _determineSaveContent(
  AppState state,
  AppBloc appBloc,
  ManagerBloc managerBloc,
) {
  return state is AppReady
      ? _saveContent(state, appBloc, managerBloc)
      : Center(child: SizedBox(height: 69, width: 69, child: ProgressRing()));
}

ListView _saveContent(
  AppState state,
  AppBloc appBloc,
  ManagerBloc managerBloc,
) {
  state as AppReady;
  print(state.editingIndex);
  final saves = state.saves;
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
      final buildNumber = meta.gameBuildNumber;
      return ListTile.selectable(
        leading: SizedBox(
          height: 100,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            //TODO: screenshot
            child: Container(
              decoration: BoxDecoration(
                border: .all(color: accentColor.toAccentColor().darkest),
              ),
              child: screenshot,
            ),
          ),
        ),
        title: state.editingIndex == index
            ? Row(
                children: [
                  Expanded(
                    child: TextBox(
                      placeholder: name,
                      maxLines: 1,
                      // onChanged: (value) =>
                      // appBloc.add(AppSaveNameChange(name: value)),
                      onSubmitted: (value) {
                        managerBloc.add(
                          ManagerRenameSave(name: name, newName: value),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: WindowsIcon(
                      FluentIcons.accept,
                      size: 10,
                      color: Colors.blue.toAccentColor().lightest,
                    ),
                    onPressed: () => appBloc.add(AppSaveNameEdit(index: -1)),
                  ),
                  IconButton(
                    icon: WindowsIcon(
                      FluentIcons.cancel,
                      size: 10,
                      color: Colors.red.toAccentColor().lightest,
                    ),
                    onPressed: () => appBloc.add(AppSaveNameEdit(index: -1)),
                  ),
                ],
              )
            : Row(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(name, style: .new(color: accentColor)),
                  IconButton(
                    icon: WindowsIcon(
                      FluentIcons.edit,
                      size: 10,
                      color: Colors.blue.toAccentColor().lightest,
                    ),
                    onPressed: () => appBloc.add(AppSaveNameEdit(index: index)),
                  ),
                ],
              ),
        subtitle: Column(
          crossAxisAlignment: .start,
          children: [
            Text('PCU:$pcu'),
            Text('Version: $gameVersion'),
            Text('Ticks: $ticks'),
            Text('Build Number: $buildNumber'),
          ],
        ),
        selectionMode: .single,
        // selected: , //TODO:
        // onSelectionChange: (v) => bloc, //TODO:
      );
    },
  );
}
