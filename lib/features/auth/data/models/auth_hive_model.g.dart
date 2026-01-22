// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = 1;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModel(
      userId: fields[0] as String?,
      firstname: fields[1] as String,
      lastname: fields[2] as String,
      email: fields[3] as String,
      password: fields[4] as String,
      number: fields[5] as String?,
      age: fields[6] as int?,
      gender: fields[7] as String?,
      bio: fields[8] as String?,
      interests: fields[9] as String?,
      photos: fields[10] as String?,
      location: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.firstname)
      ..writeByte(2)
      ..write(obj.lastname)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.number)
      ..writeByte(6)
      ..write(obj.age)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.bio)
      ..writeByte(9)
      ..write(obj.interests)
      ..writeByte(10)
      ..write(obj.photos)
      ..writeByte(11)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
