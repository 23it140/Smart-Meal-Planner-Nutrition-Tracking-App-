// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionGoalAdapter extends TypeAdapter<NutritionGoal> {
  @override
  final int typeId = 2;

  @override
  NutritionGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionGoal(
      id: fields[0] as String,
      targetCalories: fields[1] as double,
      targetProtein: fields[2] as double,
      targetCarbs: fields[3] as double,
      targetFats: fields[4] as double,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionGoal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.targetCalories)
      ..writeByte(2)
      ..write(obj.targetProtein)
      ..writeByte(3)
      ..write(obj.targetCarbs)
      ..writeByte(4)
      ..write(obj.targetFats)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
