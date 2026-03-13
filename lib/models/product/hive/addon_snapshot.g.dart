// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addon_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAddonSnapshotAdapter extends TypeAdapter<HiveAddonSnapshot> {
  @override
  final int typeId = 0;

  @override
  HiveAddonSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAddonSnapshot(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAddonSnapshot obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAddonSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
