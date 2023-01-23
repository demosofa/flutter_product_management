import 'package:product_manager/utils/class_util.dart';

class Product implements ClassUtil {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? note;
  int? cost;
  int? price;
  int? init;
  int? sold;
  int? brandId;

  Product();
  Product.necc(this.name, this.phone, this.address, this.note, this.cost,
      this.price, this.init, this.sold, this.brandId);
  Product.full(this.id, this.name, this.phone, this.address, this.note,
      this.cost, this.price, this.init, this.sold, this.brandId);

  @override
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "address": address,
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
    return Product.full(
        map['id'],
        map['name'],
        map['phone'],
        map['address'],
        map['note'],
        map['cost'],
        map['price'],
        map['init'],
        map['sold'],
        map['brandId']);
  }
}
