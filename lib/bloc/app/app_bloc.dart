import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/models/save.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitial()) {
    on<AppManagerBusy>(_appMangerBusy);
    on<AppManagerReady>(_appMangerReady);
  }

  void _appMangerBusy(AppManagerBusy event, Emitter<AppState> emit) {
    emit(const AppBusy());
  }

  void _appMangerReady(AppManagerReady event, Emitter<AppState> emit) {
    emit(AppReady(saves: event.saves));
  }
}
