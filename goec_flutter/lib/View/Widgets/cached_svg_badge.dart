import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Rasterizes an SVG once (at device pixel ratio) and reuses the [ui.Image].
/// Much cheaper than painting [SvgPicture] inside scrolling list rows.
class SvgRasterCache {
  SvgRasterCache._();

  static final Map<String, ui.Image> _cache = {};
  static final Map<String, Future<ui.Image?>> _inflight = {};

  static String _key(String asset, double logicalPx, double dpr) =>
      '$asset|${logicalPx.toStringAsFixed(1)}|${dpr.toStringAsFixed(2)}';

  static ui.Image? getSync(
    String asset, {
    required double logicalPx,
    required double devicePixelRatio,
  }) =>
      _cache[_key(asset, logicalPx, devicePixelRatio)];

  static Future<ui.Image?> precache(
    String asset, {
    required double logicalPx,
    required double devicePixelRatio,
  }) {
    final key = _key(asset, logicalPx, devicePixelRatio);
    final cached = _cache[key];
    if (cached != null) return Future<ui.Image?>.value(cached);

    return _inflight.putIfAbsent(key, () async {
      try {
        final pictureInfo = await vg.loadPicture(SvgAssetLoader(asset), null);
        final pixelSize =
            (logicalPx * devicePixelRatio).clamp(1, 2048).ceil();
        final src = pictureInfo.size;
        final scale = pixelSize /
            (src.longestSide <= 0 ? logicalPx : src.longestSide);

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.scale(scale);
        final dx = (pixelSize / scale - src.width) / 2;
        final dy = (pixelSize / scale - src.height) / 2;
        canvas.translate(dx, dy);
        canvas.drawPicture(pictureInfo.picture);

        final raster = recorder.endRecording();
        final image = await raster.toImage(pixelSize, pixelSize);
        pictureInfo.picture.dispose();
        raster.dispose();

        _cache[key] = image;
        return image;
      } catch (_) {
        return null;
      } finally {
        _inflight.remove(key);
      }
    });
  }

  static Future<void> precacheAll(
    List<String> assets, {
    required double logicalPx,
    required double devicePixelRatio,
  }) {
    return Future.wait(
      assets.map(
        (asset) => precache(
          asset,
          logicalPx: logicalPx,
          devicePixelRatio: devicePixelRatio,
        ),
      ),
    );
  }
}

/// Displays a precached raster SVG. Prefer [image] from [SvgRasterCache]
/// when rendering many list rows so nothing async happens during scroll.
class CachedSvgBadge extends StatelessWidget {
  final ui.Image? image;
  final double size;
  final Widget? placeholder;

  const CachedSvgBadge({
    super.key,
    required this.image,
    required this.size,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return placeholder ?? SizedBox(width: size, height: size);
    }
    return RawImage(
      image: image,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.low,
    );
  }
}
