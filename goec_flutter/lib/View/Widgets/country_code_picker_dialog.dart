import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants.dart';

class CountryCode {
  final String name;
  final String dialCode;
  final String code;
  final String flag;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.code,
    required this.flag,
  });

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      name: json['name'] as String? ?? '',
      dialCode: json['dialCode'] as String? ?? '',
      code: json['code'] as String? ?? '',
      flag: json['flag'] as String? ?? '🌐',
    );
  }

  static const List<CountryCode> defaultCountries = [
    CountryCode(name: 'Nepal', dialCode: '+977', code: 'NP', flag: '🇳🇵'),
    CountryCode(name: 'India', dialCode: '+91', code: 'IN', flag: '🇮🇳'),
    CountryCode(name: 'United States', dialCode: '+1', code: 'US', flag: '🇺🇸'),
    CountryCode(name: 'United Kingdom', dialCode: '+44', code: 'GB', flag: '🇬🇧'),
    CountryCode(name: 'United Arab Emirates', dialCode: '+971', code: 'AE', flag: '🇦🇪'),
    CountryCode(name: 'Australia', dialCode: '+61', code: 'AU', flag: '🇦🇺'),
    CountryCode(name: 'Bangladesh', dialCode: '+880', code: 'BD', flag: '🇧🇩'),
    CountryCode(name: 'Bhutan', dialCode: '+975', code: 'BT', flag: '🇧🇹'),
    CountryCode(name: 'Canada', dialCode: '+1', code: 'CA', flag: '🇨🇦'),
    CountryCode(name: 'China', dialCode: '+86', code: 'CN', flag: '🇨🇳'),
    CountryCode(name: 'Saudi Arabia', dialCode: '+966', code: 'SA', flag: '🇸🇦'),
    CountryCode(name: 'Qatar', dialCode: '+974', code: 'QA', flag: '🇶🇦'),
    CountryCode(name: 'Singapore', dialCode: '+65', code: 'SG', flag: '🇸🇬'),
    CountryCode(name: 'Malaysia', dialCode: '+60', code: 'MY', flag: '🇲🇾'),
    CountryCode(name: 'Germany', dialCode: '+49', code: 'DE', flag: '🇩🇪'),
    CountryCode(name: 'France', dialCode: '+33', code: 'FR', flag: '🇫🇷'),
  ];
}

class CountryCodePickerDialog extends StatefulWidget {
  final CountryCode selectedCountry;

  const CountryCodePickerDialog({
    super.key,
    required this.selectedCountry,
  });

  static Future<CountryCode?> show(
    BuildContext context, {
    CountryCode selectedCountry = const CountryCode(
      name: 'Nepal',
      dialCode: '+977',
      code: 'NP',
      flag: '🇳🇵',
    ),
  }) {
    return showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryCodePickerDialog(
        selectedCountry: selectedCountry,
      ),
    );
  }

  @override
  State<CountryCodePickerDialog> createState() =>
      _CountryCodePickerDialogState();
}

class _CountryCodePickerDialogState extends State<CountryCodePickerDialog> {
  List<CountryCode> _countries = CountryCode.defaultCountries;
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/country_codes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _countries = jsonList
            .map((item) => CountryCode.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _countries = CountryCode.defaultCountries;
        _isLoading = false;
      });
    }
  }

  List<CountryCode> get _filteredCountries {
    if (_query.trim().isEmpty) return _countries;
    final q = _query.toLowerCase().trim();
    return _countries.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.dialCode.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Country Code',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: kNeutralPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: kNeutralSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _query = val),
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  color: kNeutralPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search country or dialing code...',
                  hintStyle: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    color: kNeutralMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: kNeutralMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Country List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: const Color(0xFFF1F5F9),
                      indent: 16.w,
                      endIndent: 16.w,
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredCountries[index];
                      final isSelected =
                          item.dialCode == widget.selectedCountry.dialCode &&
                              item.code == widget.selectedCountry.code;

                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        tileColor: isSelected
                            ? kBrandPrimaryBlue.withValues(alpha: 0.08)
                            : Colors.transparent,
                        leading: Text(
                          item.flag,
                          style: TextStyle(fontSize: 22.sp),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: kNeutralPrimary,
                          ),
                        ),
                        trailing: Text(
                          item.dialCode,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? kBrandPrimaryBlue
                                : kNeutralSecondary,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
