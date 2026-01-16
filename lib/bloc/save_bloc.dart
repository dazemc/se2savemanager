import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'save_state.dart';
part 'save_event.dart';

class SaveBloc extends Bloc<SaveEvent, SaveState> {
  SaveBloc() : super(const SaveInitial()) {
    //TODO:
  }
}
