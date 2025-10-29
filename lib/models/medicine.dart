import 'package:hive/hive.dart';
 // not required but harmless if present

/// Medicine model stored in Hive.
/// Note: we include a manual TypeAdapter below so you do not need build_runner.

class Medicine {
  int? key; // hive key (set when saved)
  String name;
  String notes;
  int doseAmount;
  String doseUnit;
  String frequency;
  List<String> times; // list of HH:mm strings (multi-times)
  bool enabled;
  String status; // 'pending' | 'taken' | 'missed'
  String profile; // profile name, e.g., 'Me','Dad'

  Medicine({
    this.key,
    required this.name,
    this.notes = '',
    this.doseAmount = 1,
    this.doseUnit = 'pills',
    this.frequency = 'Daily',
    required this.times,
    this.enabled = true,
    this.status = 'pending',
    this.profile = 'Me',
  });

  /// Convert to map for CSV or debug
  Map<String, dynamic> toMap() => {
        'key': key,
        'name': name,
        'notes': notes,
        'doseAmount': doseAmount,
        'doseUnit': doseUnit,
        'frequency': frequency,
        'times': times.join(','),
        'enabled': enabled ? 1 : 0,
        'status': status,
        'profile': profile,
      };

  factory Medicine.fromMap(Map<String, dynamic> m) {
    return Medicine(
      key: m['key'] as int?,
      name: m['name'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
      doseAmount: m['doseAmount'] as int? ?? 1,
      doseUnit: m['doseUnit'] as String? ?? 'pills',
      frequency: m['frequency'] as String? ?? 'Daily',
      times: (m['times'] as String? ?? '08:00').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      enabled: (m['enabled'] as int? ?? 1) == 1,
      status: m['status'] as String? ?? 'pending',
      profile: m['profile'] as String? ?? 'Me',
    );
  }
}

/// Manual TypeAdapter for Medicine (so build_runner is not required).
class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    // fields mapping:
    // 0: name, 1: notes, 2:doseAmount, 3:doseUnit, 4:frequency, 5:times, 6:enabled, 7:status, 8:profile
    final med = Medicine(
      name: fields[0] as String,
      notes: fields[1] as String? ?? '',
      doseAmount: fields[2] as int? ?? 1,
      doseUnit: fields[3] as String? ?? 'pills',
      frequency: fields[4] as String? ?? 'Daily',
      times: (fields[5] as List).cast<String>(),
      enabled: fields[6] as bool? ?? true,
      status: fields[7] as String? ?? 'pending',
      profile: fields[8] as String? ?? 'Me',
    );

    return med;
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.name);
    writer.writeByte(1);
    writer.write(obj.notes);
    writer.writeByte(2);
    writer.write(obj.doseAmount);
    writer.writeByte(3);
    writer.write(obj.doseUnit);
    writer.writeByte(4);
    writer.write(obj.frequency);
    writer.writeByte(5);
    writer.write(obj.times);
    writer.writeByte(6);
    writer.write(obj.enabled);
    writer.writeByte(7);
    writer.write(obj.status);
    writer.writeByte(8);
    writer.write(obj.profile);
  }
}
