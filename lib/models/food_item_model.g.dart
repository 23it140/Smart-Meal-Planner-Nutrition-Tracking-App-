// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 0;

  @override
  FoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodItem(
      id: fields[0] as String,
      name: fields[1] as String,
      caloriesPer100g: fields[2] as double,
      proteinPer100g: fields[3] as double,
      carbsPer100g: fields[4] as double,
      fatsPer100g: fields[5] as double,
      category: fields[6] as String,
      isCustom: fields[7] as bool,
      unit: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.caloriesPer100g)
      ..writeByte(3)
      ..write(obj.proteinPer100g)
      ..writeByte(4)
      ..write(obj.carbsPer100g)
      ..writeByte(5)
      ..write(obj.fatsPer100g)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.isCustom)
      ..writeByte(8)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
