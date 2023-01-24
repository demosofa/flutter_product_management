import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
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
  @override
  void initState() {
    if (widget.data != null) {
      product = widget.data!;
      title = "Cập nhật sản phẩm";
    }
    super.initState();
  }

  Future<void> create() async {
    final db = await SQLiteHelper.open();
    if (db != null && db.isOpen) {
      await db.transaction((txn) async {
        if (widget.data == null) {
          await txn.insert("Product", product.toMap());
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
        child: ListView(
          itemExtent: 50,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                  hintText: "Tên sản phẩm",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.person),
                  )),
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
                  hintText: "Chi phí",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.currency_exchange),
                  )),
              keyboardType: TextInputType.number,
              inputFormatters: [
                MaskTextInputFormatter(
                    mask: '#,##0.00',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy)
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
                  hintText: "Giá cả",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.price_change),
                  )),
              keyboardType: TextInputType.number,
              inputFormatters: [
                MaskTextInputFormatter(
                    mask: '#,##0.00',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy)
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
                  hintText: "Số lượng nhập hàng",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.currency_exchange),
                  )),
              keyboardType: TextInputType.number,
              inputFormatters: [
                MaskTextInputFormatter(
                    mask: '#,##0.00',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy)
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
                  hintText: "Chú ý",
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.note),
                  )),
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
          ],
        ),
      ),
    );
  }
}
