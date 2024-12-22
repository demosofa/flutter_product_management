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

  Future<bool> refresh() async {
    final listJson = listHistory.map((e) => e.toJson()).toList();
    final result = await store.setStringList(key, listJson);
    notifyListeners();
    return result;
  }

  Future<bool> add(History history) async {
    listHistory.add(history);
    return await refresh();
  }

  Future<bool> removeAt(int index) async {
    listHistory.removeAt(index);
    return await refresh();
  }
}
