part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class AppStart extends AppEvent {
  const AppStart();
}

final class AppManagerBusy extends AppEvent {
  const AppManagerBusy();
}

final class AppManagerReady extends AppEvent {
  final List<Save> saves;
  const AppManagerReady({required this.saves});
}

final class AppSaveNameEdit extends AppEvent {
  final int index;
  const AppSaveNameEdit({required this.index});
}

final class AppSaveNameChange extends AppEvent {
  final String name;
  const AppSaveNameChange({required this.name});
}

final class AppSaveNameDone extends AppEvent {
  final String name;
  const AppSaveNameDone({required this.name});
}
