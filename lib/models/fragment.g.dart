// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fragment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FragmentAdapter extends TypeAdapter<Fragment> {
  @override
  final int typeId = 0;

  @override
  Fragment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fragment(
      imagePath: fields[0] as String?,
      audioPath: fields[1] as String?,
      text: fields[2] as String,
      timestamp: fields[3] as DateTime,
      moodTag: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Fragment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.audioPath)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.moodTag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FragmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
