abstract class AModel<T> {
  //todo: fromMap
  //todo: get props
  Map<String, Object?> get toMap;
  dynamic get(String propertyName) {
    if (!toMap.containsKey(propertyName)) return null;
    return toMap[propertyName];
  }
}
