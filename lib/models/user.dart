import 'package:product_manager/abstract/model.abstract.dart';

class User extends AModel<User> {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? note;

  User();
  User.nec(this.name, this.phone, this.address, this.note);
  User.full(this.id, this.name, this.phone, this.address, this.note);

  factory User.fromMap(Map<String, dynamic>? map) {
    if (map == null) return User();
    return User.full(
        map['id'], map['name'], map['phone'], map['address'], map['note']);
  }

  @override
  Map<String, Object?> get toMap => ({
        "id": id,
        "name": name,
        "phone": phone,
        "address": address,
        "note": note,
      });

  static List<String> get props => ["id", "name", "phone", "address", "note"];
}
