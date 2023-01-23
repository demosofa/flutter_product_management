import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:product_manager/helpers/sqlite_helper.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/screens/create_update_brand.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? generateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split("/");
    inspect(pathElements);

    if (pathElements[0] != "") {
      return null;
    }
    if (pathElements[1] == 'create_update_brand') {
      return PageRouteBuilder(
        pageBuilder: ((context, animation, secondaryAnimation) {
          return CreateUpdateBrand(
            data: Brand().fromMap(settings.arguments as Map<String, dynamic>),
          );
        }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Map<String, Object?>>> fetchProduct() async {
    List<Map<String, Object?>> lstBrand = [];
    final db = await SQLiteHelper.open();
    if (db != null && db.isOpen == true) {
      await db.transaction((txn) async {
        lstBrand = await txn.query("Brand");
      });
    }
    // log('get db path: ${db!.path}');
    // await SQLiteHelper.delete();
    // inspect(lstBrand);
    return lstBrand;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: fetchProduct(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Text('Loading');
          } else {
            return ListView(children: <Widget>[
              for (var i = 0; i < snapshot.data!.length; i++)
                GestureDetector(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(snapshot.data![i]["name"].toString()),
                            Text(snapshot.data![i]["phone"].toString())
                          ],
                        )
                      ]),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed("/create_update_brand",
                            arguments: snapshot.data![i])
                        .then((value) => setState(
                              () {},
                            ));
                  },
                )
            ]);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CreateUpdateBrand()));
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
