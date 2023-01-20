import 'package:product_manager/utils/class_util.dart';

class Product implements ClassUtil {
  String? name;
  String? phone;
  String? address;
  int? cost;
  int? price;
  int? init;
  int? sold;

  Product();
  Product.full(this.name, this.phone, this.address, this.cost, this.price,
      this.init, this.sold);

  @override
  Map<String, Object?> toMap() {
    return {
      "name": name,
      "phone": phone,
      "address": address,
      "init": init,
      "sold": sold
    };
  }
}
