import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_manager/enums/history_type.dart';
import 'package:product_manager/enums/table_name.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/models/product.dart';
import 'package:product_manager/notifiers/history/history.dart';
import 'package:product_manager/notifiers/history/history_notifier.dart';
import 'package:product_manager/notifiers/history/inherited_history.dart';
import 'package:string_validator/string_validator.dart';

class CreateUpdateProduct extends StatefulWidget {
  const CreateUpdateProduct({super.key, this.iniData});

  final Product? iniData;

  @override
  State<CreateUpdateProduct> createState() => _CreateUpdateProductState();
}

class _CreateUpdateProductState extends State<CreateUpdateProduct> {
  Product product = Product();
  String title = "Thêm sản phẩm";
  String dropdownBrand = "";
  final tableProductName = TableName.product.name;
  final _formKey = GlobalKey<FormState>();
  late final _costController =
      TextEditingController(text: product.cost.toString());
  late final _priceController =
      TextEditingController(text: product.price.toString());
  late HistoryNotifier _historyNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.iniData != null) {
      title = "Cập nhật sản phẩm";
      product = widget.iniData!;
      dropdownBrand = product.brandId.toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _historyNotifier = InheritedHistory.of(context);
  }

  Future<List<Map<String, Object?>>> fetchBrand() async {
    // await Future.delayed(const Duration(microseconds: 1));
    List<Map<String, Object?>> lstBrand = [];
    final db = await SQLiteHelper.db;
    if (db.isOpen) {
      lstBrand = await db.query(TableName.brand.name);
    }
    if (lstBrand.isEmpty && context.mounted) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: const Text("No brands available"),
                content: const Text("Do you want to create new Brand?"),
                actions: [
                  OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed("/create_update_brand")
                            .then((value) {
                          Navigator.pop(dialogContext);
                          setState(() {});
                        });
                      },
                      child: const Text("Ok")),
                ],
              ));
    }
    return lstBrand;
  }

  Future<List<Map<String, dynamic>>> fetchImages() async {
    List<Map<String, Object?>> lstImage = [];
    final db = await SQLiteHelper.db;
    if (db.isOpen && product.id != null && context.mounted) {
      lstImage = await db.query(TableName.anyFile.name,
          where: "productId = ?", whereArgs: [product.id]);
    }
    return lstImage;
  }

  Future<void> delete() async {
    final db = await SQLiteHelper.db;
    if (db.isOpen && context.mounted) {
      await db.transaction((txn) async {
        await txn
            .delete(tableProductName, where: "id = ?", whereArgs: [product.id]);
      }).then((value) {
        final history = History(
            type: HistoryType.delete.name,
            table: tableProductName,
            data: product.id!);
        _historyNotifier.add(history);
        Navigator.pop(context);
      });
    }
  }

  Future<void> create() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = await SQLiteHelper.db;
    if (db.isOpen && context.mounted) {
      await db.transaction((txn) async {
        if (widget.iniData == null) {
          await txn.insert(tableProductName, product.toMap()).then((_) {
            final history = History(
                type: HistoryType.insert.name,
                table: tableProductName,
                data: product.toMap());
            _historyNotifier.add(history);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sản phẩm đã được tạo")));
          });
        } else {
          await txn.update(tableProductName, product.toMap(),
              where: 'id = ?', whereArgs: [product.id]);
          final history = History(
              type: HistoryType.update.name,
              table: tableProductName,
              data: product.toMap());
          _historyNotifier.add(history);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.iniData != null)
            InkWell(
              onTap: delete,
              child: const Icon(Icons.delete),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
        child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FutureBuilder(
                    future: fetchBrand(),
                    builder: (brandContext, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('Loading');
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                    hint: const Text("Brand"),
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
                                    items: snapshot.data!.map((e) {
                                      final brand = Brand.fromMap(e);
                                      return DropdownMenuItem<String>(
                                        value: brand.id.toString(),
                                        child: GestureDetector(
                                            onLongPress: () {
                                              Navigator.of(context)
                                                  .pushNamed(
                                                      "/create_update_brand",
                                                      arguments: brand)
                                                  .then((value) {
                                                Navigator.pop(brandContext);
                                                setState(() {});
                                              });
                                            },
                                            child: Text(brand.name.toString())),
                                      );
                                    }).toList()),
                              ),
                              const Spacer(flex: 1),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                            context, "/create_update_brand")
                                        .then((value) => setState(() {}));
                                  },
                                  child: const Text("Tạo thương hiệu mới"))
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  // FutureBuilder(
                  //   future: fetchImages(),
                  //   builder: (context, snapshot) {
                  //     if (!snapshot.hasData) {
                  //       return const SizedBox.shrink();
                  //     }
                  //     return GridView.builder(
                  //       itemCount: snapshot.data!.length,
                  //       gridDelegate:
                  //           const SliverGridDelegateWithFixedCrossAxisCount(
                  //               crossAxisCount: 3,
                  //               mainAxisSpacing: 10,
                  //               crossAxisSpacing: 10),
                  //       itemBuilder: (context, index) {
                  //         return Container(
                  //           decoration: BoxDecoration(
                  //               image: DecorationImage(
                  //                   fit: BoxFit.contain,
                  //                   image: FileImage(
                  //                       File(snapshot.data![index]["path"])))),
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
                  // const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Tên sản phẩm",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.person),
                        ),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    keyboardType: TextInputType.name,
                    inputFormatters: [LengthLimitingTextInputFormatter(25)],
                    initialValue: product.name,
                    onSaved: (value) {
                      product.name = value;
                    },
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return "Xin hãy điền tên sản phẩm";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                        labelText: "Chi phí",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.currency_exchange),
                        ),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (value) {
                      product.cost = int.parse(value!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy điền chi phí";
                      } else if (!isNumeric(value) || int.parse(value) < 0) {
                        return "Xin hãy điền giá trị là số";
                      } else if (int.parse(value) >
                          int.parse(_priceController.value.text)) {
                        return "Xin hãy điền giá trị bé hơn giá trị giá cả";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                        labelText: "Giá cả",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.price_change),
                        ),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (value) {
                      product.price = int.parse(value!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy điền giá cả";
                      } else if (!isNumeric(value) || int.parse(value) < 0) {
                        return "Xin hãy điền giá trị là số";
                      } else if (int.parse(value) <
                          int.parse(_costController.value.text)) {
                        return "Xin hãy điền giá trị lớn hơn giá trị chi phí";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Số lượng nhập hàng",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.currency_exchange),
                        ),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    initialValue: product.init.toString(),
                    onSaved: (value) {
                      product.init = int.parse(value!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Xin hãy điền số lượng nhập hàng";
                      } else if (!isNumeric(value) || int.parse(value) < 0) {
                        return "Xin hãy điền giá trị là số tự nhiên";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Chú ý",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(Icons.note),
                        ),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    initialValue: product.note,
                    onSaved: (newValue) {
                      product.note = newValue;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: create, child: const Text("Submit")))
                ])),
      ),
    );
  }
}
