// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemDataAdapter extends TypeAdapter<SystemData> {
  @override
  final int typeId = 0;

  @override
  SystemData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemData(
      musicVolume: fields[0] as double,
      sfxVolume: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SystemData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.musicVolume)
      ..writeByte(1)
      ..write(obj.sfxVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
