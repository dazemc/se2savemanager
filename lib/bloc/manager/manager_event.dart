part of 'manager_bloc.dart';

sealed class ManagerEvent {
  const ManagerEvent();
}

class ManagerStart extends ManagerEvent {
  const ManagerStart();
}

class ManagerReload extends ManagerEvent {
  const ManagerReload();
}

class ManagerRenameSave extends ManagerEvent {
  final String newName;
  final String name;
  const ManagerRenameSave({required this.name, required this.newName});
}
