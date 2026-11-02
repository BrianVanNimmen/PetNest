import 'dart:convert';

/// Lenient JSON decoding, the equivalent of Gson's `setLenient()`: tolerates a
/// BOM, whitespace or a PHP notice/warning printed before the JSON.
/// Returns null for an empty body.
dynamic decodeLenient(String body) {
  final start = body.indexOf(RegExp(r'[\[{]'));
  if (start < 0) {
    if (body.trim().isEmpty) return null;
    throw FormatException('Response is not JSON', body);
  }
  return jsonDecode(body.substring(start));
}

/// PHP/MySQL may return numbers as strings ("5"); Gson converted those
/// silently, so we do the same.
int? asInt(dynamic value) => switch (value) {
  int v => v,
  num v => v.toInt(),
  String v => int.tryParse(v.trim()),
  _ => null,
};

String? asString(dynamic value) => switch (value) {
  null => null,
  String v => v,
  _ => value.toString(),
};

Map<String, dynamic>? asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : null;

List<Map<String, dynamic>> asMapList(dynamic value) =>
    value is List ? value.whereType<Map<String, dynamic>>().toList() : const [];
