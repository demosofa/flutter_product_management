import 'package:product_manager/abstract/model.abstract.dart';

class Product extends AModel<Product> {
  int? id;
  String? name;
  String? note;
  int price = 0;
  int cost = 0;
  int init = 0;
  int sold = 0;
  int? brandId;

  Product();
  Product.nec(this.name, this.note, this.price, this.cost, this.init, this.sold,
      this.brandId);
  Product.full(this.id, this.name, this.note, this.price, this.cost, this.init,
      this.sold, this.brandId);

  factory Product.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Product();
    return Product.full(map['id'], map['name'], map['note'], map['price'],
        map['cost'], map['init'], map['sold'], map['brandId']);
  }

  @override
  Map<String, Object?> get toMap => ({
        "id": id,
        "name": name,
        "note": note,
        "price": price,
        "cost": cost,
        "init": init,
        "sold": sold,
        "brandId": brandId
      });

  static List<String> get props =>
      ["id", "name", "note", "price", "cost", "init", "sold", "brandId"];
}
