import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/services/save_manager.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitial()) {
    on<AppStart>(_appInit);
    add(AppStart());
  }

  Future<void> _appInit(AppStart event, Emitter<AppState> emit) async {
    emit(const AppBusy());
    final log = SaveLogger(name: pid.toString()).log;
    final saveManager = SaveManager();
    await saveManager.init();
    saveManager.box.put('name', 'test');
    final dynamic name = saveManager.box.get('name');
    assert(name is String);
    log.info(name);
    saveManager.watcher.start();
    log.info('Non-blocking test');
    emit(const AppReady());
  }
}
