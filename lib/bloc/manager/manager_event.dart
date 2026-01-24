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

class ManagerDeleteSave extends ManagerEvent {
  final Save save;
  const ManagerDeleteSave({required this.save});
}

class ManagerCopySave extends ManagerEvent {
  final Save save;
  const ManagerCopySave({required this.save});
}
