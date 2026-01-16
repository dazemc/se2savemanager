part of 'save_bloc.dart';

sealed class SaveEvent {
  const SaveEvent();
}

final class SaveAppStarted extends SaveEvent {
  const SaveAppStarted();
}
