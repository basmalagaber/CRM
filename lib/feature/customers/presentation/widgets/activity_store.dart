import 'package:flutter/foundation.dart';

class ActivityStore {
  ActivityStore._();
  static final ActivityStore instance = ActivityStore._();

  final Map<String, List<Map<String, dynamic>>> _data = {};

  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  List<Map<String, dynamic>> of(String customerKey) =>
      List.unmodifiable(_data[customerKey] ?? const []);

  void add(String customerKey, Map<String, dynamic> activity) {
    _data.putIfAbsent(customerKey, () => []).insert(0, activity);
    changes.value++;
  }
}