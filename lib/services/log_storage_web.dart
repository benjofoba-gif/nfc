// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';

import 'dart:html' as html;

import '../models/log_access.dart';

class LogStorage {
  static const String _storageKey = 'access_logs';

  Future<List<LogAccess>> loadLogs() async {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.isEmpty) return <LogAccess>[];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((item) => LogAccess.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLogs(List<LogAccess> logs) async {
    final raw = json.encode(logs.map((l) => l.toJson()).toList());
    html.window.localStorage[_storageKey] = raw;
  }

  Future<void> addLog(LogAccess log) async {
    final logs = await loadLogs();
    logs.add(log);
    await saveLogs(logs);
  }

  Future<void> clearLogs() async {
    html.window.localStorage.remove(_storageKey);
  }

  Future<void> close() async {}
}
