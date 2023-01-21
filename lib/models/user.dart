import 'package:product_manager/utils/class_util.dart';

class User implements ClassUtil {
  String? name;
  String? phone;
  String? address;
  String? note;

  User();
  User.full(this.name, this.phone, this.address, this.note);

  @override
  Map<String, Object?> toMap() {
    return {
      "name": name,
      "phone": phone,
      "address": address,
      "note": note,
    };
  }
}
