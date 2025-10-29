import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> exportFile(String csvData) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/madcep_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  await file.writeAsString(csvData);
  return file.path;
}
