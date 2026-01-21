import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:se2savemanager/bloc/app/app_bloc.dart';
import 'package:se2savemanager/bloc/manager/manager_bloc.dart';
import 'package:se2savemanager/main.dart';

Widget _determineSaveContent(
  AppState state,
  AppBloc appBloc,
  ManagerBloc managerBloc,
) {
  //TODO: GridView when fullscreen
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
      return Padding(
        padding: .all(2),
        child: Align(
          alignment: .centerLeft,
          child: Column(
            children: [
              SizedBox(
                width: 600,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: .circular(8),
                    border: .all(color: Colors.grey),
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      height: 156,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            border: .all(
                              color: accentColor.toAccentColor().darkest,
                            ),
                          ),
                          child: screenshot,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        state.editingIndex == index
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 182,
                                    child: TextBox(
                                      placeholder: name,
                                      maxLines: 1,
                                      onChanged: (value) => appBloc.add(
                                        AppSaveNameChange(name: value),
                                      ),
                                      onSubmitted: (value) {
                                        managerBloc.add(
                                          ManagerRenameSave(
                                            name: name,
                                            newName: value,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Accept',
                                    child: IconButton(
                                      icon: WindowsIcon(
                                        FluentIcons.accept,
                                        size: 10,
                                        color: Colors.blue.lightest,
                                      ),
                                      onPressed: () => managerBloc.add(
                                        ManagerRenameSave(
                                          name: name,
                                          newName: state.editingName ?? name,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Cancel',
                                    child: IconButton(
                                      icon: WindowsIcon(
                                        FluentIcons.cancel,
                                        size: 10,
                                        color: Colors.red.lightest,
                                      ),
                                      onPressed: () =>
                                          appBloc.add(AppSaveNameCancel()),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(name, style: .new(color: accentColor)),
                                  Tooltip(
                                    message: 'Rename',
                                    child: IconButton(
                                      icon: WindowsIcon(
                                        FluentIcons.edit,
                                        size: 10,
                                        color: Colors.blue.lightest,
                                      ),
                                      onPressed: () => appBloc.add(
                                        AppSaveNameEdit(index: index),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        Spacer(),
                        Tooltip(
                          message: 'Copy',
                          child: IconButton(
                            icon: WindowsIcon(
                              FluentIcons.copy,
                              size: 10,
                              color: Colors.green.lightest,
                            ),
                            onPressed: () =>
                                managerBloc.add(ManagerDeleteSave(name: name)),
                          ),
                        ),
                        Tooltip(
                          message: 'Delete',
                          child: IconButton(
                            icon: WindowsIcon(
                              FluentIcons.delete,
                              size: 10,
                              color: Colors.red.lightest,
                            ),
                            onPressed: () =>
                                managerBloc.add(ManagerDeleteSave(name: name)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: SizedBox(
                      height: 150,
                      child: Expander(
                        header: Text(
                          'Metadata',
                          style: .new(fontStyle: .italic),
                        ),
                        content: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text('PCU: $pcu'),
                            Text('Version: $gameVersion'),
                            Text('Ticks: $ticks'),
                            Text('Build Number: $buildNumber'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

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
