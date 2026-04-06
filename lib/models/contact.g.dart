// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 0;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return Contact(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      jobTitle: fields[3] as String?,
      company: fields[4] as String?,
      phone: fields[5] as String?,
      email: fields[6] as String?,
      source: fields[7] as String?,
      project: fields[8] as String?,
      interest: fields[9] as String?,
      notes: fields[10] as String?,
      tags: (fields[11] as List?)?.cast<String>() ?? [],
      status: fields[12] as String? ?? 'warm',
      createdAt: fields[13] as DateTime? ?? DateTime.now(),
      lastContactDate: fields[14] as DateTime?,
      avatarColor: fields[15] as String?,
      captureMethod: fields[16] as String? ?? 'manual',
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.jobTitle)
      ..writeByte(4)
      ..write(obj.company)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.project)
      ..writeByte(9)
      ..write(obj.interest)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.lastContactDate)
      ..writeByte(15)
      ..write(obj.avatarColor)
      ..writeByte(16)
      ..write(obj.captureMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
