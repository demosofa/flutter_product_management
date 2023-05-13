import 'dart:developer';

import 'package:flutter/material.dart';

class _ImageCacheCustom extends ImageCache {
  @override
  void clear() {
    log("run clear image");
    super.clear();
  }
}

class MyImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() => _ImageCacheCustom();
}
