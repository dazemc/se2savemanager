part of 'save_bloc.dart';

sealed class SaveEvent {
  const SaveEvent();
}

final class SaveAppInit extends SaveEvent {
  const SaveAppInit();
}
