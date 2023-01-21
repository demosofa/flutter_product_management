import 'package:product_manager/utils/class_util.dart';

class Product implements ClassUtil {
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
  Product.full(this.name, this.phone, this.address, this.note, this.cost,
      this.price, this.init, this.sold, this.brandId);

  @override
  Map<String, Object?> toMap() {
    return {
      "name": name,
      "phone": phone,
      "address": address,
      "note": note,
      "init": init,
      "sold": sold,
      "brandId": brandId
    };
  }
}
