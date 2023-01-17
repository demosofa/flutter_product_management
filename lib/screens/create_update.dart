import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';

import '../models/product.dart';

class CreateUpdate extends StatefulWidget {
  final String? id;
  const CreateUpdate({super.key, this.id});

  @override
  State<CreateUpdate> createState() => _CreateUpdateState();
}

class _CreateUpdateState extends State<CreateUpdate> {
  final _formKey = GlobalKey<FormState>();
  final product = Product();
  String title = "Create";

  @override
  void initState() {
    if (widget.id != null) {
      setState(() {
        title = "Update";
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
          await txn.update("Product", product.toMap(),
              where: "id = ?", whereArgs: [widget.id]);
        });
      } else {
        await db!.transaction((txn) async {
          await txn.insert("Product", product.toMap());
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
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: product.customerName,
                  onSaved: (value) {
                    product.customerName = value;
                  },
                  validator: (value) {
                    if (value?.isNotEmpty == true) return null;
                    return "Please fill name";
                  },
                  keyboardType: TextInputType.name,
                  inputFormatters: [LengthLimitingTextInputFormatter(25)],
                  decoration: const InputDecoration(
                      hintText: "Tên khách hàng",
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Icon(Icons.person),
                      )),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: product.address,
                  onSaved: (value) {
                    product.address = value;
                  },
                  validator: (value) {
                    if (value?.isNotEmpty == true) return null;
                    return "Please fill address";
                  },
                  keyboardType: TextInputType.streetAddress,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  decoration: const InputDecoration(
                      hintText: "Địa chỉ nhà",
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Icon(Icons.streetview),
                      )),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: product.phone,
                  onSaved: (value) {
                    product.phone = value;
                  },
                  validator: (value) {
                    if (value?.isNotEmpty == true) return null;
                    return "Please fill phone number";
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
                const SizedBox(height: 20),
                ElevatedButton(onPressed: create, child: const Text("Submit"))
              ],
            )),
      ),
    );
  }
}
