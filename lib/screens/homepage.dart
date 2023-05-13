import 'package:flutter/material.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/models/product.dart';
import 'package:product_manager/screens/create_update_product.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, this.title});
  final String? title;
  final List<NavigationDestination> routes = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.history), label: 'History')
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIdx = 0;
  String title = "Demo";
  String dropdownBrand = "All";
  List<String> productColumns = Product().props.sublist(1);
  int sortIdx = 1;
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.title != null) {
        title = widget.title!;
      } else {
        title = widget.routes[currentPageIdx].label;
      }
    });
    imageCache.clear();
  }

  Future<List<Map<String, Object?>>> fetchBrand() async {
    List<Map<String, Object?>> lstBrand = [];
    final db = await SQLiteHelper.db;
    if (db.isOpen) {
      await db.transaction((txn) async {
        lstBrand = await txn.query("Brand");
      });
    }
    return lstBrand;
  }

  Future<List<Map<String, Object?>>> fetchProduct() async {
    List<Map<String, Object?>> lstProduct = [];
    String orderQuery =
        "${Product().props[sortIdx]} ${isAscending ? "ASC" : "DESC"}";
    final db = await SQLiteHelper.db;
    if (db.isOpen) {
      await db.transaction((txn) async {
        if (dropdownBrand == "All") {
          lstProduct = await txn.query("Product", orderBy: orderQuery);
        } else {
          lstProduct = await txn.query("Product",
              where: "brandId = ?",
              whereArgs: [dropdownBrand],
              orderBy: orderQuery);
        }
      });
    }
    return lstProduct;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: widget.routes,
        selectedIndex: currentPageIdx,
        onDestinationSelected: (value) {
          setState(() {
            currentPageIdx = value;
            title = widget.routes[value].label;
          });
        },
      ),
      body: [
        SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: fetchBrand(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const Text('Loading');
                  } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 15, left: 40),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButton<String>(
                          hint: const Text("Brand"),
                          items: [
                            DropdownMenuItem(
                              value: "All",
                              child: GestureDetector(child: const Text("All")),
                            ),
                            ...snapshot.data!.map((e) {
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
                                    child: Text(brand.name!)),
                              );
                            }).toList()
                          ],
                          value: dropdownBrand,
                          onChanged: (value) {
                            setState(() {
                              dropdownBrand = value.toString();
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              FutureBuilder(
                  future: fetchProduct(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) return const Text("Loading");
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: <Widget>[
                              DataTable(
                                  sortColumnIndex: sortIdx,
                                  sortAscending: isAscending,
                                  columns: <DataColumn>[
                                    const DataColumn(label: Text("No.")),
                                    for (var i = 0;
                                        i < productColumns.length;
                                        i++)
                                      DataColumn(
                                        label: Text(productColumns[i]),
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            sortIdx = columnIndex;
                                            isAscending = ascending;
                                          });
                                        },
                                      )
                                  ],
                                  rows: snapshot.data!.asMap().entries.map(
                                    (e) {
                                      int key = e.key;
                                      var value = e.value;
                                      Product product =
                                          Product().fromMap(value);
                                      return DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text((key + 1).toString())),
                                          ...productColumns.map((col) =>
                                              DataCell(Text(
                                                  product.get(col).toString())))
                                        ],
                                        onLongPress: () {
                                          Navigator.of(context)
                                              .pushNamed(
                                                  "/create_update_product",
                                                  arguments: product)
                                              .then((value) => setState(() {}));
                                        },
                                      );
                                    },
                                  ).toList()),
                            ],
                          ),
                        ));
                  })
            ],
          ),
        )
      ][currentPageIdx],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const CreateUpdateProduct()))
              .then((value) => setState(() {}));
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
