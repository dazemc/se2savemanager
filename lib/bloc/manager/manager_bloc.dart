import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:se2savemanager/models/save.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/services/save_manager.dart';

part 'manager_event.dart';
part 'manager_state.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  static final _log = SaveLogger(name: 'ManagerBloc').log;
  static late final SaveManager saveManager;
  ManagerBloc() : super(const ManagerInitial()) {
    on<ManagerStart>(_managerInit);
    add(ManagerStart());
    on<ManagerReload>(_managerReload);
    on<ManagerRenameSave>(_managerRenameSave);
    on<ManagerDeleteSave>(_managerDeleteSave);
  }

  Future<void> _managerInit(
    ManagerStart event,
    Emitter<ManagerState> emit,
  ) async {
    try {
      emit(const ManagerBusy());
      saveManager = SaveManager(onChange: _onChange);
      await saveManager.init();
      final saves = await saveManager.getLocalSaves();
      emit(ManagerReady(saves: saves));
    } catch (e) {
      //TODO: proper error handling
      _log.severe(e);
      emit(const ManagerBusy());
    }
  }

  Future<void> _managerReload(
    ManagerReload event,
    Emitter<ManagerState> emit,
  ) async {
    emit(ManagerBusy());
    await saveManager.reload();
    final saves = await saveManager.getLocalSaves();
    emit(ManagerReady(saves: saves));
  }

  Future<void> _managerRenameSave(
    ManagerRenameSave event,
    Emitter<ManagerState> emit,
  ) async {
    emit(ManagerBusy());
    if (event.name != event.newName && event.newName.isNotEmpty) {
      _log.info('Changing name: ${event.name} => ${event.newName}');
      saveManager.renameSave(event.name, event.newName);
    }
    add(ManagerReload());
  }

  Future<void> _onChange(String path) async {
    _log.info('Change detected at: $path');
    add(ManagerReload());
  }

  Future<void> _managerDeleteSave(
    ManagerDeleteSave event,
    Emitter<ManagerState> emit,
  ) async {
    emit(ManagerBusy());
    final path = (saveManager.box as Map<String, String>).values.first;
    final save = Directory(path);
    if (await save.exists()) {
      _log.warning('Deleting save: ${event.name}');
      await save.delete();
    }
    emit(ManagerReady(saves: await saveManager.getLocalSaves()));
  }
}
