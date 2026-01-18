part of 'manager_bloc.dart';

sealed class ManagerState extends Equatable {
  const ManagerState();

  @override
  List<Object> get props => [];
}

class ManagerInitial extends ManagerState {
  const ManagerInitial();
}

class ManagerBusy extends ManagerState {
  const ManagerBusy();
}

class ManagerReady extends ManagerState {
  const ManagerReady();
}
