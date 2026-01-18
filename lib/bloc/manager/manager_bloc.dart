import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:se2savemanager/models/save.dart';
import 'package:se2savemanager/services/save_logger.dart';
import 'package:se2savemanager/services/save_manager.dart';

part 'manager_event.dart';
part 'manager_state.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  static final _log = SaveLogger(name: 'ManagerBloc').log;
  ManagerBloc() : super(const ManagerInitial()) {
    on<ManagerStart>(_managerInit);
    add(ManagerStart());
  }

  Future<void> _managerInit(
    ManagerStart event,
    Emitter<ManagerState> emit,
  ) async {
    try {
      emit(const ManagerBusy());
      final saveManager = SaveManager();
      await saveManager.init();
      // saveManager.box.put('name', 'test');
      // final dynamic name = saveManager.box.get('name');
      // assert(name is String);
      // _log.info(name);
      saveManager.watcher.start();
      final saves = await saveManager.getLocalSaves();
      emit(ManagerReady(saves: saves));
    } catch (e) {
      //TODO: proper error handling
      _log.severe(e);
      emit(const ManagerBusy());
    }
  }
}
