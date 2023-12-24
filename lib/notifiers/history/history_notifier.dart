import 'package:flutter/foundation.dart';
import 'package:product_manager/notifiers/history/history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryNotifier extends ChangeNotifier {
  static const key = 'list-history';
  late List<History> listHistory;
  late SharedPreferences store;

  HistoryNotifier() {
    SharedPreferences.getInstance().then((value) {
      store = value;
      final listJson = store.getStringList(key);
      if (listJson != null && listJson.isNotEmpty) {
        listHistory = listJson.map((e) => History.fromJson(e)).toList();
      } else {
        listHistory = [];
      }
    });
  }

  Future<bool> add(History history) {
    listHistory.add(history);
    final listJson = listHistory.map((e) => e.toJson()).toList();
    return store.setStringList(key, listJson);
  }

  Future<bool> removeAt(int index) {
    listHistory.removeAt(index);
    final listJson = listHistory.map((e) => e.toJson()).toList();
    return store.setStringList(key, listJson);
  }
}
