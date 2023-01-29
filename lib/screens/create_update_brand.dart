import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';

import '../models/brand.dart';

class CreateUpdateBrand extends StatefulWidget {
  final Brand? data;
  const CreateUpdateBrand({super.key, this.data});

  @override
  State<CreateUpdateBrand> createState() => _CreateUpdateBrandState();
}

class _CreateUpdateBrandState extends State<CreateUpdateBrand> {
  Brand brand = Brand();
  String title = "Tạo Thương Hiệu";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.data != null) {
      setState(() {
        title = "Cập nhật Thương Hiệu";
        brand = widget.data!;
      });
    }
    super.initState();
  }

  Future<void> create() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = await SQLiteHelper.open();
    await db!.transaction((txn) async {
      if (widget.data == null) {
        await txn.insert("Brand", brand.toMap()).then((_) => showDialog(
            context: context,
            builder: ((context) => Dialog(
                    child: SizedBox(
                  width: 200,
                  height: 150,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        direction: Axis.vertical,
                        children: <Widget>[
                          const Text("Thành công thêm Thương hiệu mới"),
                          Text(jsonEncode(brand.toMap())),
                          Wrap(
                            children: <Widget>[
                              TextButton(
                                  onPressed: (() {
                                    Navigator.pop(context);
                                  }),
                                  child: const Text("Ok"))
                            ],
                          )
                        ],
                      )),
                )))));
      } else {
        await txn.update("Brand", brand.toMap(),
            where: "id = ?", whereArgs: [brand.id]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Tên thương hiệu",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.person),
                        ),
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.name,
                    inputFormatters: [LengthLimitingTextInputFormatter(25)],
                    initialValue: brand.name,
                    onSaved: (value) {
                      brand.name = value;
                    },
                    validator: (value) {
                      if (value?.isNotEmpty == true) return null;
                      return "Xin hãy điền tên thương hiệu";
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Địa chỉ nhập hàng",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.streetview),
                        ),
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.streetAddress,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    initialValue: brand.address,
                    onSaved: (value) {
                      brand.address = value;
                    },
                    validator: (value) {
                      if (value?.isNotEmpty == true) return null;
                      return "Xin hãy điền địa chỉ nhập hàng";
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.phone),
                        ),
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      MaskTextInputFormatter(
                          mask: '+# (###) ###-##-##',
                          filter: {"#": RegExp(r'[0-9]')},
                          type: MaskAutoCompletionType.lazy)
                    ],
                    initialValue: brand.phone,
                    onSaved: (value) {
                      brand.phone = value;
                    },
                    validator: (value) {
                      if (value?.isNotEmpty == true) return null;
                      return "Xin hãy điền điện thoại liên hệ nhập hàng";
                    },
                  ),
                  const SizedBox(height: 10),
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
                    initialValue: brand.note,
                    onSaved: (newValue) {
                      brand.note = newValue;
                    },
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
