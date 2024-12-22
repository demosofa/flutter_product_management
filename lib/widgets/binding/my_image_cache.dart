import 'dart:developer';

import 'package:flutter/widgets.dart';

class MyImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() => _ImageCacheCustom();
}

class _ImageCacheCustom extends ImageCache {
  @override
  void clear() {
    log("run clear image");
    super.clear();
  }
}
