abstract class ModelUtil<T> {
  List<String> get props;
  Map<String, Object?> get toMap;
  dynamic get(String propertyName);
  T fromMap(Map<String, Object?> map);
}
