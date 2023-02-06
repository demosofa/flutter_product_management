import 'package:product_manager/utils/model_util.dart';

class Product implements ModelUtil {
  int? id;
  String? name;
  String? note;
  int cost = 0;
  int price = 0;
  int init = 0;
  int sold = 0;
  int? brandId;

  Product();
  Product.necc(this.name, this.note, this.cost, this.price, this.init,
      this.sold, this.brandId);
  Product.full(this.id, this.name, this.note, this.cost, this.price, this.init,
      this.sold, this.brandId);

  @override
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "note": note,
      "cost": cost,
      "price": price,
      "init": init,
      "sold": sold,
      "brandId": brandId
    };
  }

  @override
  Product fromMap(Map<String, dynamic> map) {
    return Product.full(map['id'], map['name'], map['note'], map['cost'],
        map['price'], map['init'], map['sold'], map['brandId']);
  }
}
