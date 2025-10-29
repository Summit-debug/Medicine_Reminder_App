import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mad_cep/models/medicine.dart';
import 'package:csv/csv.dart';

// ✅ conditional import for export logic
import 'hive_helper_io.dart' if (dart.library.html) 'hive_helper_web.dart';

class HiveHelper {
  static const String boxName = 'medicines_box';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    await Hive.openBox<Medicine>(boxName);
  }

  static Box<Medicine> get box => Hive.box<Medicine>(boxName);

  static List<Medicine> getAll({String profile = 'Me'}) {
    final list = box.values.toList();
    return list.where((m) => m.profile == profile).toList();
  }

  static Future<void> addMedicine(Medicine m) async {
    await box.add(m);
  }

  static Future<void> updateMedicineAt(int index, Medicine m) async {
    await box.putAt(index, m);
  }

  static Future<void> deleteAt(int index) async {
    await box.deleteAt(index);
  }

  static Future<void> clearAll() async => await box.clear();

  /// Export all medicines to CSV. On web triggers download, on mobile writes to documents and returns path.
  static Future<String?> exportToCsv() async {
    final rows = <List<dynamic>>[
      ['id', 'name', 'notes', 'doseAmount', 'doseUnit', 'frequency', 'times', 'enabled', 'status', 'profile']
    ];
    int id = 0;
    for (final m in box.values) {
      rows.add([
        id,
        m.name,
        m.notes,
        m.doseAmount,
        m.doseUnit,
        m.frequency,
        m.times.join(','),
        m.enabled ? '1' : '0',
        m.status,
        m.profile
      ]);
      id++;
    }

    final csvData = const ListToCsvConverter().convert(rows);
    return await exportFile(csvData); // ✅ platform-specific implementation
  }
}
