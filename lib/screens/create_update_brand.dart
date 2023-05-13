import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/any_file.dart';

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
  final ImageHelper _imageHelper = ImageHelper();

  final _formKey = GlobalKey<FormState>();

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

  Future<Map<String, dynamic>?> _getImg() async {
    if (widget.iniData == null) {
      return null;
    }
    final db = await SQLiteHelper.db;
    return db.query("AnyFile",
        where: "brandId = ?", whereArgs: [brand.id]).then((value) => value[0]);
  }

  Future<void> create() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = await SQLiteHelper.db;
    await db.transaction((txn) async {
      int? brandId;
      if (widget.iniData == null) {
        brandId = await txn.insert("Brand", brand.toMap);
      } else {
        brandId = brand.id;
        await txn.update("Brand", brand.toMap,
            where: "id = ?", whereArgs: [brandId]);
      }
      if (imagePath != null) {
        String path = (await getApplicationDocumentsDirectory()).path;
        path += imagePath!.split("/").last;
        final compressed = await _imageHelper.compress(imagePath!, path);
        final imageStat = await File(imagePath!).stat();
        final imageData = await getImg;
        final imageBrand = AnyFile().fromMap(imageData);
        imageBrand.type = imageStat.type.toString();
        imageBrand.size = imageStat.size;
        imageBrand.brandId = brandId;
        if (widget.iniData == null) {
          imageBrand.path = compressed?.path;
          await txn.insert("AnyFile", imageBrand.toMap);
        } else {
          _imageHelper.delete(imageBrand.path!);
          imageBrand.path = compressed?.path;
          await txn.update("AnyFile", imageBrand.toMap,
              where: "id = ?", whereArgs: [imageBrand.id]);
        }
      }
    }).then((_) => showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) => Dialog(
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
                      Text(jsonEncode(brand.toMap)),
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
            ))));
  }

  Future<void> delete() async {
    final db = await SQLiteHelper.db;
    if (db.isOpen && context.mounted) {
      await db.transaction((txn) async {
        await txn.delete("Brand", where: "id = ?", whereArgs: [brand.id]);
      }).then((value) => Navigator.pop(context));
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
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
              sliver: SliverFillRemaining(
                child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Center(
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
                                          iconTitle
                                              .substring(0, 2)
                                              .toUpperCase(),
                                          style: const TextStyle(fontSize: 48)),
                                    );
                                  })),
                        )),
                        const SizedBox(height: 30),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Tên thương hiệu",
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(Icons.person),
                              ),
                              border: OutlineInputBorder()),
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200)
                          ],
                          initialValue: brand.note,
                          onSaved: (newValue) {
                            brand.note = newValue;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: create, child: const Text("Submit"))
                      ],
                    )),
              ),
            )
          ],
        ));
  }
}
