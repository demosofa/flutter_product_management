import 'package:product_manager/utils/class_util.dart';

class Brand implements ClassUtil {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? note;

  Brand();
  Brand.necc(this.name, this.phone, this.address, this.note);
  Brand.full(this.id, this.name, this.phone, this.address, this.note);

  @override
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "address": address,
      "note": note
    };
  }

  @override
  Brand fromMap(Map<String, dynamic> map) {
    return Brand.full(
        map['id'], map['name'], map['phone'], map['address'], map['note']);
  }
}
