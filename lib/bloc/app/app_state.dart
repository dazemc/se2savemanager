part of 'app_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

final class AppInitial extends AppState {
  const AppInitial();
}

final class AppBusy extends AppState {
  const AppBusy();
}

final class AppReady extends AppState {
  const AppReady();
}
