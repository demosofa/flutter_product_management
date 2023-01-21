import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';

import '../models/brand.dart';

class CreateUpdateBrand extends StatefulWidget {
  final String? id;
  const CreateUpdateBrand({super.key, this.id});

  @override
  State<CreateUpdateBrand> createState() => _CreateUpdateBrandState();
}

class _CreateUpdateBrandState extends State<CreateUpdateBrand> {
  final _formKey = GlobalKey<FormState>();
  final brand = Brand();
  String title = "Tạo Thương Hiệu";

  @override
  void initState() {
    if (widget.id != null) {
      setState(() {
        title = "Cập nhật Thương Hiệu";
      });
    }
    super.initState();
  }

  Future<void> create() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = await SQLiteHelper.open();
      if (widget.id != null) {
        await db!.transaction((txn) async {
          await txn.update("Brand", brand.toMap(),
              where: "id = ?", whereArgs: [widget.id]);
        });
      } else {
        await db!.transaction((txn) async {
          await txn.insert("Brand", brand.toMap());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: brand.name,
                    onSaved: (value) {
                      brand.name = value;
                    },
                    validator: (value) {
                      if (value?.isNotEmpty == true) return null;
                      return "Xin hãy điền tên thương hiệu";
                    },
                    keyboardType: TextInputType.name,
                    inputFormatters: [LengthLimitingTextInputFormatter(25)],
                    decoration: const InputDecoration(
                        hintText: "Tên thương hiệu",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.person),
                        )),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: brand.address,
                    onSaved: (value) {
                      brand.address = value;
                    },
                    validator: (value) {
                      if (value?.isNotEmpty == true) return null;
                      return "Xin hãy điền địa chỉ nhập hàng";
                    },
                    keyboardType: TextInputType.streetAddress,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    decoration: const InputDecoration(
                        hintText: "Địa chỉ nhập hàng",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.streetview),
                        )),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: brand.phone,
                    onSaved: (value) {
                      brand.phone = value;
                    },
                    validator: (value) {
                      if (value?.isNotEmpty == true) return null;
                      return "Xin hãy điền điện thoại liên hệ nhập hàng";
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      MaskTextInputFormatter(
                          mask: '+# (###) ###-##-##',
                          filter: {"#": RegExp(r'[0-9]')},
                          type: MaskAutoCompletionType.lazy)
                    ],
                    decoration: const InputDecoration(
                        hintText: "Số điện thoại",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.phone),
                        )),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: brand.note,
                    onSaved: (newValue) {
                      brand.note = newValue;
                    },
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    decoration: const InputDecoration(
                        hintText: "Chú ý",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.note),
                        )),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: create, child: const Text("Submit"))
                ],
              ),
            )),
      ),
    );
  }
}
