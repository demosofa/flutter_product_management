abstract class ModelUtil<T> {
  List<String> get props;
  Map<String, Object?> get toMap;
  T fromMap(Map<String, Object?>? map);
  dynamic get(String propertyName) {
    if (!toMap.containsKey(propertyName)) return null;
    return toMap[propertyName];
  }
}
