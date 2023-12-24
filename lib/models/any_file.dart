import 'package:product_manager/abstract/model.abstract.dart';

class AnyFile extends AModel<AnyFile> {
  int? id;
  String? path;
  String? type;
  int? size;
  int? userId;
  int? brandId;
  int? productId;

  AnyFile();

  AnyFile.nec(this.path, this.type, this.size, this.userId, this.brandId,
      this.productId);

  AnyFile.full(this.id, this.path, this.type, this.size, this.userId,
      this.brandId, this.productId);

  factory AnyFile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AnyFile();
    return AnyFile.full(map['id'], map['path'], map['type'], map['size'],
        map['userId'], map['brandId'], map['productId']);
  }

  @override
  Map<String, Object?> toMap() => ({
        "id": id,
        "path": path,
        "type": type,
        "size": size,
        "userId": userId,
        "brandId": brandId,
        "productId": productId
      });

  static List<String> get props =>
      ["id", "path", "type", "size", "userId", "brandId", "productId"];
}
