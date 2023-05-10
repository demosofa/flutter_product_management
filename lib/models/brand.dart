import 'package:product_manager/utils/model_util.dart';

class Brand extends ModelUtil<Brand> {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? note;

  Brand();
  Brand.nec(this.name, this.phone, this.address, this.note);
  Brand.full(this.id, this.name, this.phone, this.address, this.note);

  @override
  List<String> get props => ["id", "name", "phone", "address", "note"];

  @override
  Map<String, Object?> get toMap => ({
        "id": id,
        "name": name,
        "phone": phone,
        "address": address,
        "note": note
      });

  @override
  Brand fromMap(Map<String, dynamic>? map) {
    if (map == null) return Brand();
    return Brand.full(
        map['id'], map['name'], map['phone'], map['address'], map['note']);
  }
}
