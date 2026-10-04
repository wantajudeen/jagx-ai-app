import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConnectorsStore {
  static const _key = 'jx_mcp_connected';

  /// Returns list of enabled connectors as maps for the backend.
  static Future<List<Map<String, dynamic>>> enabled() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final out = <Map<String, dynamic>>[];
      m.forEach((id, v) {
        if (v is! Map) return;
        final row = Map<String, dynamic>.from(v);
        if (row['enabled'] == false) return;
        out.add({
          'id': id,
          'name': row['name'] ?? id,
          'url': row['url'] ?? '',
          'auth': row['auth'] ?? '',
          'token': row['token'],
          'enabled': true,
        });
      });
      return out;
    } catch (_) {
      return [];
    }
  }
}
