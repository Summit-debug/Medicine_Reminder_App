import 'dart:convert';
import 'dart:html' as html;

Future<String?> exportFile(String csvData) async {
  final bytes = const Utf8Encoder().convert(csvData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'madcep_export_${DateTime.now().millisecondsSinceEpoch}.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
  return null;
}
