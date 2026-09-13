import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  final url = imageUrl.trim();
  if (url.isEmpty ||
      !(url.startsWith('http://') || url.startsWith('https://'))) {
    return _cachedImageFallback(
      width: width,
      height: height,
      broken: true,
      child: errorWidget,
    );
  }

  return CachedNetworkImage(
    imageUrl: url,
    fit: fit ?? BoxFit.fill,
    width: width,
    height: height,
    fadeInDuration: const Duration(milliseconds: 150),
    fadeOutDuration: const Duration(milliseconds: 100),
    // Static placeholder — avoids an endless spinner on slow/broken URLs.
    placeholder: (context, _) =>
        placeholder ??
        _cachedImageFallback(width: width, height: height, broken: false),
    errorWidget: (context, _, __) =>
        errorWidget ??
        _cachedImageFallback(width: width, height: height, broken: true),
  );
}

Widget _cachedImageFallback({
  double? width,
  double? height,
  required bool broken,
  Widget? child,
}) {
  if (child != null) return child;
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFE8EEF5),
    alignment: Alignment.center,
    child: Icon(
      broken ? Icons.broken_image_outlined : Icons.image_outlined,
      color: const Color(0xFFA0AABD),
      size: 28,
    ),
  );
}
