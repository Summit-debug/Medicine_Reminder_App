import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mad_cep/helpers/hive_helper.dart';
import 'package:mad_cep/helpers/notification_helper.dart';
import 'package:mad_cep/models/medicine.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> medicines = [];
  String activeProfile = 'Me';
  List<String> profiles = ['Me', 'Dad', 'Mom'];
  late Box<Medicine> _box;

  Future<void> init() async {
    await HiveHelper.init();
    _box = Hive.box<Medicine>(HiveHelper.boxName);
    loadMedicines();
  }

  void loadMedicines() {
    medicines = _box.values.where((m) => m.profile == activeProfile).toList();
    notifyListeners();
  }

  /// Adds and schedules notifications (mobile)
  Future<void> addMedicine(Medicine m) async {
    final int addedIndex = await _box.add(m); // returns index
    if (m.enabled && m.times.isNotEmpty && !kIsWeb) {
      await NotificationHelper.scheduleMultipleDaily(
        baseId: addedIndex,
        title: 'Time for ${m.name}',
        body: '${m.doseAmount} ${m.doseUnit}',
        times: m.times,
      );
    }
    loadMedicines();
  }

  /// Update at hive index: cancel old notifications and reschedule new ones.
  Future<void> updateMedicineAt(int hiveIndex, Medicine m) async {
    final Medicine? old = _box.getAt(hiveIndex);
    if (old != null && old.times.isNotEmpty && !kIsWeb) {
      await NotificationHelper.cancelByBaseId(hiveIndex, old.times.length);
    }

    // write updated object back into the box at the same index
    await _box.putAt(hiveIndex, m);

    if (m.enabled && m.times.isNotEmpty && !kIsWeb) {
      await NotificationHelper.scheduleMultipleDaily(
        baseId: hiveIndex,
        title: 'Time for ${m.name}',
        body: '${m.doseAmount} ${m.doseUnit}',
        times: m.times,
      );
    }
    loadMedicines();
  }

  Future<void> removeMedicineAt(int hiveIndex) async {
    final Medicine? old = _box.getAt(hiveIndex);
    if (old != null && old.times.isNotEmpty && !kIsWeb) {
      await NotificationHelper.cancelByBaseId(hiveIndex, old.times.length);
    }
    await _box.deleteAt(hiveIndex);
    loadMedicines();
  }

  Future<void> markTakenAt(int hiveIndex) async {
    final m = _box.getAt(hiveIndex);
    if (m == null) return;
    m.status = 'taken';
    // write back the modified object
    await _box.putAt(hiveIndex, m);
    loadMedicines();
  }

  Future<void> markMissedAt(int hiveIndex) async {
    final m = _box.getAt(hiveIndex);
    if (m == null) return;
    m.status = 'missed';
    // write back the modified object
    await _box.putAt(hiveIndex, m);
    loadMedicines();
  }

  Future<void> addProfile(String p) async {
    if (!profiles.contains(p)) {
      profiles.add(p);
      notifyListeners();
    }
  }

  Future<void> switchProfile(String p) async {
    activeProfile = p;
    loadMedicines();
  }

  Future<String?> exportCsv() async {
    return await HiveHelper.exportToCsv();
  }
}
