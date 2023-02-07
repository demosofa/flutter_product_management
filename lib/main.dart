import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/models/product.dart';
import 'package:product_manager/screens/create_update_brand.dart';
import 'package:product_manager/screens/create_update_product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? generateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split("/");
    inspect(settings.arguments);

    if (pathElements[0] != "") return null;

    switch (pathElements[1]) {
      case 'create_update_brand':
        return PageRouteBuilder(
          pageBuilder: ((context, animation, secondaryAnimation) {
            return CreateUpdateBrand(
              data: settings.arguments as Brand,
            );
          }),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case 'create_update_product':
        return MaterialPageRoute(builder: ((context) {
          return CreateUpdateProduct(
            data: settings.arguments as Product,
          );
        }));
      default:
    }
    return null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder()
          })),
      onGenerateRoute: generateRoute,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, this.title});
  final String? title;
  final List<NavigationDestination> routes = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.history), label: 'History')
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIdx = 0;
  String title = "Demo";
  String dropdownBrand = "All";

  @override
  void initState() {
    setState(() {
      if (widget.title != null) {
        title = widget.title!;
      } else {
        title = widget.routes[currentPageIdx].label;
      }
    });
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
    // log('get db path: ${db!.path}');
    // await SQLiteHelper.delete();
    // inspect(lstBrand);
    return lstBrand;
  }

  Future<List<Map<String, Object?>>> fetchProduct(String brand) async {
    List<Map<String, Object?>> lstProduct = [];
    final db = await SQLiteHelper.db;
    if (db.isOpen == true) {
      await db.transaction((txn) async {
        if (brand == "All") {
          lstProduct = await txn.query("Product");
        } else {
          lstProduct = await txn
              .query("Product", where: "brandId = ?", whereArgs: [brand]);
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                      padding: const EdgeInsets.only(top: 10, left: 5.0),
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
                                  child: Text(brand.name.toString())),
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
                    );
                  }
                },
              ),
              FutureBuilder(
                  future: fetchProduct(dropdownBrand),
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: snapshot.data != null
                          ? ListView(
                              shrinkWrap: true,
                              children: snapshot.data!.map(
                                (e) {
                                  Product product = Product().fromMap(e);
                                  return InkWell(
                                    child: SizedBox(
                                      height: 70,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            // side: const BorderSide(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 4,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(product.name!),
                                            Text(product.price.toString())
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed("/create_update_product",
                                              arguments: product)
                                          .then((value) => setState(() {}));
                                    },
                                  );
                                },
                              ).toList())
                          : const Text("Loading"),
                    );
                  })
            ],
          ),
        )
      ][currentPageIdx],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CreateUpdateProduct()));
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
