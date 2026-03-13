// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveVariantSnapshotAdapter extends TypeAdapter<HiveVariantSnapshot> {
  @override
  final int typeId = 1;

  @override
  HiveVariantSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveVariantSnapshot(
      id: fields[0] as String,
      optionValues: (fields[1] as List).cast<String>(),
      price: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HiveVariantSnapshot obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.optionValues)
      ..writeByte(2)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveVariantSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
