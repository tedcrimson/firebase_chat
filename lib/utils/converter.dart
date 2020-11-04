import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Converter {
  static Widget convertToImage(String url,
      {double size, Widget placeHolder, BoxFit fit = BoxFit.cover, Color backgroundColor = Colors.white}) {
    if (placeHolder == null)
      placeHolder = Container(
        color: backgroundColor,
        width: size,
        height: size,
      );
    return url == null || url.isEmpty
        ? placeHolder
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: size,
            height: size,
          );
  }
}
