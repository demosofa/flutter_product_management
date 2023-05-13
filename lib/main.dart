import 'package:flutter/material.dart';
import 'package:product_manager/models/brand.dart';
import 'package:product_manager/models/product.dart';
import 'package:product_manager/screens/create_update_brand.dart';
import 'package:product_manager/screens/create_update_product.dart';
import 'package:product_manager/widgets/binding/my_image_cache.dart';

import 'screens/homepage.dart';

void main() {
  MyImageCache();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split("/");
    if (pathElements[0] != "") return null;
    switch (pathElements[1]) {
      case 'create_update_brand':
        return PageRouteBuilder(
            pageBuilder: ((context, animation, secondaryAnimation) {
              return CreateUpdateBrand(
                iniData: settings.arguments != null
                    ? settings.arguments as Brand
                    : null,
              );
            }),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
                      opacity: animation,
                      child: child,
                    ));
      case 'create_update_product':
        return MaterialPageRoute(builder: ((context) {
          return CreateUpdateProduct(
            iniData: settings.arguments as Product,
          );
        }));
      default:
        return null;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder()
          })),
      onGenerateRoute: onGenerateRoute,
      home: HomePage(),
    );
  }
}
