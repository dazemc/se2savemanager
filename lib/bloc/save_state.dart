part of 'save_bloc.dart';

sealed class SaveState extends Equatable {
  const SaveState();

  @override
  List<Object> get props => [];
}

final class SaveInitial extends SaveState {
  // getting saves from fs => spinner
  const SaveInitial();
}

final class SavePause extends SaveState {
  // watcher pause => updated fs
  const SavePause();
}

final class SaveInProgress extends SaveState {
  // user action => spinner on action
  const SaveInProgress();
}

final class SaveComplete extends SaveState {
  // => ListView
  const SaveComplete();
}
