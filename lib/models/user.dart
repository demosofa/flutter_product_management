import 'package:product_manager/utils/model_util.dart';

class User implements ModelUtil {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? note;

  User();
  User.necc(this.name, this.phone, this.address, this.note);
  User.full(this.id, this.name, this.phone, this.address, this.note);

  @override
  List<String> get props => ["id", "name", "phone", "address", "note"];

  @override
  Map<String, Object?> get toMap {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "address": address,
      "note": note,
    };
  }

  @override
  get(String propertyName) {
    if (!toMap.containsKey(propertyName)) return null;
    return toMap[propertyName];
  }

  @override
  User fromMap(Map<String, dynamic> map) {
    return User.full(
        map['id'], map['name'], map['phone'], map['address'], map['note']);
  }
}
