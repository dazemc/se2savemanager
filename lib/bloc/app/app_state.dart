part of 'app_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

final class AppInitial extends AppState {
  const AppInitial();
}

final class AppBusy extends AppState {
  const AppBusy();
}

final class AppReady extends AppState {
  final List<Save> saves;
  final int? editingIndex;
  final String? editingName;
  const AppReady({required this.saves, this.editingIndex, this.editingName});
  @override
  List<Object?> get props => [
    List.unmodifiable(saves),
    editingIndex,
    editingName,
  ];

  AppReady copyWith({
    List<Save>? saves,
    int? editingIndex,
    String? editingName,
  }) {
    return AppReady(
      saves: saves ?? this.saves,
      editingIndex: editingIndex ?? this.editingIndex,
      editingName: editingName ?? this.editingName,
    );
  }
}
