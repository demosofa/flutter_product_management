import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/models/product.dart';
import 'package:string_validator/string_validator.dart';

class CreateUpdateProduct extends StatefulWidget {
  const CreateUpdateProduct({super.key, this.data});
  final Product? data;
  @override
  State<CreateUpdateProduct> createState() => _CreateUpdateProductState();
}

class _CreateUpdateProductState extends State<CreateUpdateProduct> {
  Product product = Product();
  String title = "Thêm sản phẩm";
  String dropdownBrand = "";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.data != null) {
      title = "Cập nhật sản phẩm";
      product = widget.data!;
      dropdownBrand = product.brandId.toString();
    }
    super.initState();
  }

  Future<List<Map<String, Object?>>> fetchBrand() async {
    List<Map<String, Object?>> lstBrand = [];
    final db = await SQLiteHelper.db;
    if (db.isOpen == true) {
      await db.transaction((txn) async {
        lstBrand = await txn.query("Brand");
      });
    }
    return lstBrand;
  }

  Future<void> create() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = await SQLiteHelper.db;
    if (db.isOpen) {
      await db.transaction((txn) async {
        if (widget.data == null) {
          await txn.insert("Product", product.toMap()).then((_) =>
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sản phẩm đã được tạo"))));
        } else {
          await txn.update("Product", product.toMap(),
              where: 'id = ?', whereArgs: [product.id]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(itemExtent: 70, children: <Widget>[
            FutureBuilder(
              future: fetchBrand(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const Text('Loading');
                } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5.0),
                    child: DropdownButtonFormField<String>(
                      hint: const Text("Brand"),
                      items: snapshot.data!.map((e) {
                        Brand brand = Brand().fromMap(e);
                        return DropdownMenuItem<String>(
                          value: brand.id.toString(),
                          child: GestureDetector(
                              onLongPress: () {
                                Navigator.of(context)
                                    .pushNamed("/create_update_brand",
                                        arguments: brand)
                                    .then((value) => setState(
                                          () {},
                                        ));
                              },
                              child: Text(brand.name.toString())),
                        );
                      }).toList(),
                      value: dropdownBrand.isNotEmpty
                          ? dropdownBrand
                          : snapshot.data!.first["id"].toString(),
                      onChanged: (value) {
                        setState(() {
                          dropdownBrand = value.toString();
                        });
                      },
                      onSaved: (newValue) {
                        product.brandId = int.parse(newValue!);
                      },
                    ),
                  );
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Tên sản phẩm",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.person),
                  ),
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.name,
              inputFormatters: [LengthLimitingTextInputFormatter(25)],
              initialValue: product.name,
              onSaved: (value) {
                product.name = value;
              },
              validator: (value) {
                if (value?.isNotEmpty == true) return null;
                return "Xin hãy điền tên sản phẩm";
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Chi phí",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.currency_exchange),
                  ),
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue: product.cost.toString(),
              onSaved: (value) {
                product.cost = int.parse(value!);
              },
              validator: (value) {
                if (value!.isNotEmpty == true || !isNumeric(value)) {
                  return null;
                }
                return "Xin hãy điền chi phí";
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Giá cả",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.price_change),
                  ),
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue: product.price.toString(),
              onSaved: (value) {
                product.price = int.parse(value!);
              },
              validator: (value) {
                if (value?.isNotEmpty == true) return null;
                return "Xin hãy điền giá cả";
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Số lượng nhập hàng",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.currency_exchange),
                  ),
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              initialValue: product.cost.toString(),
              onSaved: (value) {
                product.cost = int.parse(value!);
              },
              validator: (value) {
                if (value!.isNotEmpty == true || !isNumeric(value)) {
                  return null;
                }
                return "Xin hãy điền số lượng nhập hàng";
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Chú ý",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.note),
                  ),
                  border: OutlineInputBorder()),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              initialValue: product.note,
              onSaved: (newValue) {
                product.note = newValue;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: create, child: const Text("Submit"))
          ]),
        ),
      ),
    );
  }
}
