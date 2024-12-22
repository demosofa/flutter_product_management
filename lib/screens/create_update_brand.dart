import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:product_manager/enums/history_type.dart';
import 'package:product_manager/enums/table_name.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/any_file.dart';
import 'package:product_manager/notifiers/history/history.dart';
import 'package:product_manager/notifiers/history/history_notifier.dart';
import 'package:product_manager/notifiers/history/inherited_history.dart';

import '../models/brand.dart';
import '../helpers/image_helper.dart';

class CreateUpdateBrand extends StatefulWidget {
  final Brand? iniData;

  const CreateUpdateBrand({super.key, this.iniData});

  @override
  State<CreateUpdateBrand> createState() => _CreateUpdateBrandState();
}

class _CreateUpdateBrandState extends State<CreateUpdateBrand> {
  String title = "Tạo Thương Hiệu";
  String iconTitle = "BR";
  Brand brand = Brand();
  String? imagePath;
  Future<Map<String, dynamic>?>? getImg;
  final tableBrandName = TableName.brand.name;
  final _imageHelper = ImageHelper();
  final _formKey = GlobalKey<FormState>();
  late HistoryNotifier _historyNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.iniData != null) {
      setState(() {
        title = "Cập nhật Thương Hiệu";
        brand = widget.iniData!;
        iconTitle = brand.name!;
        getImg = _getImg();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _historyNotifier = InheritedHistory.of(context);
  }

  Future<Map<String, dynamic>?> _getImg() async {
    if (widget.iniData == null) {
      return null;
    }
    final db = await SQLiteHelper.db;
    return db.query(TableName.anyFile.name,
        where: "brandId = ?", whereArgs: [brand.id]).then((value) {
      if (value.isEmpty) {
        return null;
      }
      return value.first;
    });
  }

  Future<void> upsert() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = await SQLiteHelper.db;
    await db.transaction((txn) async {
      int? brandId;
      if (widget.iniData == null) {
        brandId = await txn.insert(tableBrandName, brand.toMap());
        final history = History(
            type: HistoryType.insert.name,
            table: tableBrandName,
            data: brand.toMap());
        _historyNotifier.add(history);
      } else {
        brandId = brand.id;
        await txn.update(tableBrandName, brand.toMap(),
            where: "id = ?", whereArgs: [brandId]);
        final history = History(
            type: HistoryType.update.name,
            table: tableBrandName,
            data: brand.toMap());
        _historyNotifier.add(history);
      }
      if (imagePath != null) {
        String path = (await getApplicationDocumentsDirectory()).path;
        path += imagePath!.split("/").last;
        final compressed = await _imageHelper.compress(imagePath!, path);
        final imageStat = await File(imagePath!).stat();
        final imageData = await getImg;
        final imageBrand = AnyFile.fromMap(imageData);
        imageBrand.type = imageStat.type.toString();
        imageBrand.size = imageStat.size;
        imageBrand.brandId = brandId;
        if (widget.iniData == null) {
          imageBrand.path = compressed?.path;
          await txn.insert(TableName.anyFile.name, imageBrand.toMap());
        } else {
          _imageHelper.delete(imageBrand.path!);
          imageBrand.path = compressed?.path;
          await txn.update(TableName.anyFile.name, imageBrand.toMap(),
              where: "id = ?", whereArgs: [imageBrand.id]);
        }
      }
    }).then((_) {
      if (mounted) {
        final message = widget.iniData != null
            ? 'Thành công cập nhật thương hiệu'
            : 'Thành công thêm thương hiệu mới';
        return showDialog(
            context: context,
            useRootNavigator: false,
            builder: (dialogContext) => Dialog(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Flex(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          direction: Axis.vertical,
                          children: <Widget>[
                            Text(message),
                            Text(jsonEncode(brand.toMap())),
                            Wrap(
                              children: <Widget>[
                                TextButton(
                                    onPressed: (() {
                                      Navigator.pop(dialogContext);
                                    }),
                                    child: const Text("Ok"))
                              ],
                            )
                          ],
                        )),
                  ),
                )));
      }
    });
  }

  Future<void> delete() async {
    final db = await SQLiteHelper.db;
    if (db.isOpen && context.mounted) {
      await db.transaction((txn) async {
        await txn
            .delete(tableBrandName, where: "id = ?", whereArgs: [brand.id]);
      }).then((value) {
        final history = History(
            type: HistoryType.delete.name,
            table: tableBrandName,
            data: brand.id);
        _historyNotifier.add(history);
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  FileImage? loadImage(Map<String, dynamic>? data) {
    final String? path = imagePath ?? (data != null ? data["path"] : null);
    return path != null ? FileImage(File(path)) : null;
  }

  Future<void> pickImage() async {
    final file = await _imageHelper.pick(source: ImageSource.camera);
    if (file != null) {
      final cropped =
          await _imageHelper.crop(file, cropStyle: CropStyle.circle);
      if (cropped != null) {
        setState(() {
          imagePath = cropped.path;
        });
      }
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
        resizeToAvoidBottomInset: true,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
                child: Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InkWell(
                    onTap: pickImage,
                    child: FittedBox(
                        child: FutureBuilder(
                            future: getImg,
                            builder: (context, snapshot) {
                              return CircleAvatar(
                                radius: 60,
                                foregroundImage: loadImage(snapshot.data),
                                child: Text(
                                    iconTitle.substring(0, 2).toUpperCase(),
                                    style: const TextStyle(fontSize: 48)),
                              );
                            })),
                  )),
            )),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Tên thương hiệu",
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(Icons.person),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(25)
                          ],
                          initialValue: brand.name,
                          onChanged: (value) {
                            if (value.length > 1) {
                              setState(() {
                                iconTitle = value;
                              });
                            }
                          },
                          onSaved: (value) {
                            brand.name = value;
                          },
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return "Xin hãy điền tên thương hiệu";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Địa chỉ nhập hàng",
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(Icons.streetview),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                          keyboardType: TextInputType.streetAddress,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100)
                          ],
                          initialValue: brand.address,
                          onSaved: (value) {
                            brand.address = value;
                          },
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return "Xin hãy điền địa chỉ nhập hàng";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Số điện thoại",
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(Icons.phone),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            MaskTextInputFormatter(
                                mask: '+# (###) ###-##-##',
                                filter: {"#": RegExp(r'\d')},
                                type: MaskAutoCompletionType.lazy)
                          ],
                          initialValue: brand.phone,
                          onSaved: (value) {
                            brand.phone = value;
                          },
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return "Xin hãy điền điện thoại liên hệ nhập hàng";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200)
                          ],
                          initialValue: brand.note,
                          onSaved: (newValue) {
                            brand.note = newValue;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                            onPressed: upsert, child: const Text("Submit"))
                      ],
                    )),
              ),
            )
          ],
        ));
  }
}
