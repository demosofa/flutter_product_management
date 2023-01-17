import 'package:product_manager/utils/class_util.dart';

class Product implements ClassUtil {
  String? customerName;
  String? phone;
  String? address;
  String? favGas;
  String? gift;
  Product();
  Product.full(this.customerName, this.phone, this.address, this.favGas);
  Product.withGift(
      this.customerName, this.phone, this.address, this.favGas, this.gift);
  @override
  Map<String, Object?> toMap() {
    return {
      "customeName": customerName,
      "phone": phone,
      "address": address,
      "favGas": favGas,
      "gift": gift
    };
  }
}
