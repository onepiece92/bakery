// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveOrderItemSnapshotAdapter extends TypeAdapter<HiveOrderItemSnapshot> {
  @override
  final int typeId = 3;

  @override
  HiveOrderItemSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveOrderItemSnapshot(
      product: fields[0] as HiveProductSnapshot,
      selectedVariant: fields[1] as HiveVariantSnapshot?,
      selectedAddons: (fields[2] as List).cast<HiveAddonSnapshot>(),
      quantity: fields[3] as int,
      lineTotal: fields[4] as double,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveOrderItemSnapshot obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.selectedVariant)
      ..writeByte(2)
      ..write(obj.selectedAddons)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.lineTotal)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveOrderItemSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
