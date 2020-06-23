// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MethodAdapter extends TypeAdapter<Method> {
  @override
  final typeId = 1;

  @override
  Method read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Method(
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as int,
      fields[5] as bool,
      fields[6] as bool,
      fields[7] as double,
      fields[8] as double,
      fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Method obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.isMain)
      ..writeByte(7)
      ..write(obj.incSubtotal)
      ..writeByte(8)
      ..write(obj.expSubTotal)
      ..writeByte(9)
      ..write(obj.dateCreated);
  }
}
