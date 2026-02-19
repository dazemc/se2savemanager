// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ManagedSaveAdapter extends TypeAdapter<ManagedSave> {
  @override
  final typeId = 0;

  @override
  ManagedSave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManagedSave(
      name: fields[1] as String,
      path: fields[2] as String,
      children: (fields[3] as Map).cast<String, String>(),
      isParent: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ManagedSave obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isParent)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.children);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
