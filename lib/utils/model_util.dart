abstract class ModelUtil<T> {
  Map<String, Object?> toMap();
  T fromMap(Map<String, Object?> map);
}
