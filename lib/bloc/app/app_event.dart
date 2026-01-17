part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class AppStart extends AppEvent {
  const AppStart();
}
