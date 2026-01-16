part of 'save_bloc.dart';

sealed class SaveState extends Equatable {
  const SaveState();

  @override
  List<Object> get props => [];
}

final class SaveInitial extends SaveState {
  const SaveInitial();
}

final class SaveWatcherPause extends SaveState {
  const SaveWatcherPause();
}

final class SaveAppBusy extends SaveState {
  const SaveAppBusy();
}

final class SaveAppReady extends SaveState {
  const SaveAppReady();
}
