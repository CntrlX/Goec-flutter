import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a station amenity icon from `assets/svg/`.
/// Maps common API names → existing files; unknown names get a placeholder.
class AmenityIcon extends StatelessWidget {
  final String amenity;
  final double size;
  final Color color;

  const AmenityIcon({
    super.key,
    required this.amenity,
    this.size = 14,
    this.color = const Color(0xFF8C8C8C),
  });

  /// Amenity label (lowercased) → svg filename under assets/svg/
  static const Map<String, String> _assetFileByKey = {
    'cafe': 'cafe.svg',
    'coffee': 'coffee.svg',
    'coffe': 'coffee.svg',
    'local_cafe': 'local_cafe.svg',
    'local cafe': 'local_cafe.svg',
    'restaurant': 'restaurant.svg',
    'mall': 'mall.svg',
    'shopping': 'Shopping.svg',
    'shop': 'Shopping.svg',
    'toilet': 'toilet.svg',
    'restroom': 'toilet.svg',
    'washroom': 'toilet.svg',
    'bathroom': 'toilet.svg',
    'hotel': 'hotel.svg',
    'parking': 'parking.svg',
    'park': 'parking.svg',
    'wifi': 'wifi.svg',
    'wi-fi': 'wifi.svg',
    'wi_fi': 'wifi.svg',
  };

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Public so filters / other UIs can resolve the same path.
  static String assetPathFor(String amenity) {
    final key = _normalize(amenity);
    final file = _assetFileByKey[key] ??
        _assetFileByKey[key.replaceAll(' ', '_')] ??
        'amenity_placeholder.svg';
    return 'assets/svg/$file';
  }

  @override
  Widget build(BuildContext context) {
    final path = assetPathFor(amenity);
    return SvgPicture.asset(
      path,
      height: size,
      width: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(
        height: size,
        width: size,
        child: Icon(Icons.place_outlined, size: size, color: color),
      ),
    );
  }
}
