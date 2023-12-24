import 'dart:convert';

class History {
  late String type;
  late String table;
  late Object? data;
  late String createdAt;

  History({
    required this.type,
    required this.table,
    required this.data,
  }) : createdAt = DateTime.now().toIso8601String();

  History.fromJson(String source) {
    final result = json.decode(source) as Map<String, dynamic>;
    type = result["type"];
    table = result["table"];
    data = result["data"];
    createdAt = DateTime.now().toIso8601String();
  }

  String toJson() => json.encode(
      {"type": type, "table": table, "data": data, "createdAt": createdAt});
}
