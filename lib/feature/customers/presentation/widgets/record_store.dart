import 'package:flutter/foundation.dart';

class RecordStore {
  RecordStore._();
  static final RecordStore instance = RecordStore._();

  final Map<String, List<Map<String, String>>> _data = {};
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  List<Map<String, String>> of(String customerKey) =>
      List.unmodifiable(_data[customerKey] ?? const []);

  void add(String customerKey, Map<String, String> record) {
    _data.putIfAbsent(customerKey, () => []).insert(0, record);
    changes.value++;
  }
}