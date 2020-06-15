// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MethodAdapter extends TypeAdapter<Method> {
  @override
  Method read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Method(
      fields[1] as String,
      fields[2] as String,
      fields[4] as String,
      fields[5] as bool,
      fields[6] as bool,
    )..type = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, Method obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.colorHex)
      ..writeByte(5)
      ..write(obj.isIncluded)
      ..writeByte(6)
      ..write(obj.isMain);
  }

  @override
  // TODO: implement typeId
  int get typeId => 1;
}
