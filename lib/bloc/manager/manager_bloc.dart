import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:se2savemanager/services/save_manager.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'dart:io';

part 'manager_state.dart';
part 'manager_event.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  ManagerBloc() : super(const ManagerInitial()) {
    on<ManagerStart>(_managerInit);
    add(ManagerStart());
  }

  Future<void> _managerInit(
    ManagerStart event,
    Emitter<ManagerState> emit,
  ) async {
    //TODO: Error handling.......
    emit(const ManagerBusy());
    final log = SaveLogger(name: pid.toString()).log;
    final saveManager = SaveManager();
    await saveManager.init();
    saveManager.box.put('name', 'test');
    final dynamic name = saveManager.box.get('name');
    assert(name is String);
    log.info(name);
    saveManager.watcher.start();
    log.info('Non-blocking test');
    emit(const ManagerReady());
  }
}
