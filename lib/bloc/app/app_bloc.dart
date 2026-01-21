import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:se2savemanager/models/save.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitial()) {
    on<AppManagerBusy>(_appMangerBusy);
    on<AppManagerReady>(_appMangerReady);
    on<AppSaveNameEdit>(_appSaveNameEdit);
    on<AppSaveNameChange>(_appSaveNameChange);
    on<AppSaveNameDone>(_appSaveNameDone);
  }

  void _appMangerBusy(AppManagerBusy event, Emitter<AppState> emit) {
    emit(const AppBusy());
  }

  void _appMangerReady(AppManagerReady event, Emitter<AppState> emit) {
    emit(AppReady(saves: event.saves));
  }

  void _appSaveNameEdit(AppSaveNameEdit event, Emitter<AppState> emit) {
    if (state is AppReady) {
      final readyState = state as AppReady;
      emit(readyState.copyWith(editingIndex: event.index));
    }
  }

  void _appSaveNameChange(AppSaveNameChange event, Emitter<AppState> emit) {
    if (state is AppReady) {
      final readyState = state as AppReady;
      emit(readyState.copyWith(editingName: event.name));
    }
  }

  void _appSaveNameDone(AppSaveNameDone event, Emitter<AppState> emit) {
    if (state is AppReady) {
      final readyState = state as AppReady;
      emit(AppBusy());
    }
  }
}
