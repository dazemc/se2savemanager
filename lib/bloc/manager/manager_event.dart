part of 'manager_bloc.dart';

sealed class ManagerEvent {
  const ManagerEvent();
}

class ManagerStart extends ManagerEvent {
  const ManagerStart();
}
