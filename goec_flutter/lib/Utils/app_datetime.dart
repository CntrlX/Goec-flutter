import 'package:intl/intl.dart';

/// Central date/time handling for API strings that arrive in mixed formats.
///
/// Models keep [String] fields. Call these helpers only when displaying or
/// calculating — do not use for station open hours (`09:00` / `22:00`).
///
/// Rules:
/// - ISO with `Z` / offset → parsed as UTC, then [.toLocal].
/// - Formatted strings without zone → parsed as local wall-clock
///   (`.toLocal()` is a no-op; no wrong shift).
class AppDateTime {
  AppDateTime._();

  static const String displayDateTime = 'dd MMM yyyy, hh:mm a';
  static const String displayDate = 'dd MMM yyyy';
  static const String displayTime = 'hh:mm a';

  /// Formats the API may send for timestamps / createdAt / charging times.
  static const List<String> parseFormats = [
    'dd-MM-yyyy hh:mma',
    'dd-MM-yyyy hh:mm a',
    'dd-MM-yyyy HH:mm:ss',
    'dd-MM-yyyy HH:mm',
    'dd/MM/yyyy hh:mm a',
    'dd/MM/yyyy HH:mm:ss',
    'dd/MM/yyyy HH:mm',
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
    'yyyy-MM-ddTHH:mm:ss.SSSZ',
    'yyyy-MM-ddTHH:mm:ss.SSS',
    'yyyy-MM-ddTHH:mm:ssZ',
    'yyyy-MM-ddTHH:mm:ss',
    'dd-MM-yyyy',
    'dd/MM/yyyy',
    'yyyy-MM-dd',
  ];

  /// Parse any known API date string → device local [DateTime], or null.
  static DateTime? parse(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    // 1) ISO / RFC — respects Z and offsets, then convert to local.
    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso.toLocal();

    // 2) Known display / SQL-like formats (no zone → treated as local).
    for (final pattern in parseFormats) {
      try {
        final dt = DateFormat(pattern).parseLoose(trimmed);
        return dt.isUtc ? dt.toLocal() : dt;
      } catch (_) {}
    }

    // 3) Legacy custom: "dd-MM-yyyy hh:mm a" via split (history screens).
    try {
      return _parseLegacyHistory(trimmed);
    } catch (_) {}

    return null;
  }

  /// Full local datetime for UI. Falls back to [fallback] or raw string.
  static String format(
    String? raw, {
    String pattern = displayDateTime,
    String fallback = '--',
    bool useRawIfUnparsed = false,
  }) {
    final dt = parse(raw);
    if (dt != null) return DateFormat(pattern).format(dt);
    final trimmed = raw?.trim() ?? '';
    if (useRawIfUnparsed && trimmed.isNotEmpty) return trimmed;
    return fallback;
  }

  static String formatDate(String? raw, {String fallback = '--'}) =>
      format(raw, pattern: displayDate, fallback: fallback, useRawIfUnparsed: true);

  static String formatTime(String? raw, {String fallback = '--'}) =>
      format(raw, pattern: displayTime, fallback: fallback, useRawIfUnparsed: true);

  /// Hours + minutes between two API strings (both parsed to local).
  static List<int> differenceHoursMinutes(String? startRaw, String? endRaw) {
    final start = parse(startRaw);
    final end = parse(endRaw);
    if (start == null || end == null) return [0, 0];

    final ms = end.difference(start).inMilliseconds;
    if (ms < 0) return [0, 0];
    final hours = (ms / (1000 * 60 * 60)).floor();
    final minutes = ((ms / (1000 * 60)) % 60).floor();
    return [hours, minutes];
  }

  static DateTime _parseLegacyHistory(String input) {
    final parts = input.split(' ');
    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    if (parts.length > 2 && parts[2].toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    }
    if (parts.length > 2 && parts[2].toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  }
}
