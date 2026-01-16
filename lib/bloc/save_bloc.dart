import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/services/save_manager.dart';

part 'save_event.dart';
part 'save_state.dart';

class SaveBloc extends Bloc<SaveEvent, SaveState> {
  SaveBloc() : super(const SaveInitial()) {
    on<SaveAppStarted>(_saveInit);
    add(SaveAppStarted());
  }

  Future<void> _saveInit(SaveAppStarted event, Emitter<SaveState> emit) async {
    emit(const SaveInProgress());
    final log = SaveLogger(name: pid.toString()).log;
    final saveManager = SaveManager();
    await saveManager.init();
    saveManager.box.put('name', 'test');
    final dynamic name = saveManager.box.get('name');
    assert(name is String);
    log.info(name);
    saveManager.watcher.start();
    log.info('Non-blocking test');
    emit(const SaveComplete());
  }
}
