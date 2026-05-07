// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealEntryAdapter extends TypeAdapter<MealEntry> {
  @override
  final int typeId = 1;

  @override
  MealEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealEntry(
      id: fields[0] as String,
      foodItemId: fields[1] as String,
      foodItemName: fields[2] as String,
      mealType: fields[3] as String,
      quantity: fields[4] as double,
      calories: fields[5] as double,
      protein: fields[6] as double,
      carbs: fields[7] as double,
      fats: fields[8] as double,
      date: fields[9] as DateTime,
      isSynced: fields[10] as bool,
      unit: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MealEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.foodItemId)
      ..writeByte(2)
      ..write(obj.foodItemName)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.protein)
      ..writeByte(7)
      ..write(obj.carbs)
      ..writeByte(8)
      ..write(obj.fats)
      ..writeByte(9)
      ..write(obj.date)
      ..writeByte(10)
      ..write(obj.isSynced)
      ..writeByte(11)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
