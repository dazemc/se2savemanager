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
  const AppManagerReady();
}
