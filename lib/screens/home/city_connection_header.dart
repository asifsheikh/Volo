import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CityConnectionHeader extends StatelessWidget {
  final String fromCity;
  final String fromThumbnail;
  final String toCity;
  final String toThumbnail;

  const CityConnectionHeader({
    Key? key,
    required this.fromCity,
    required this.fromThumbnail,
    required this.toCity,
    required this.toThumbnail,
  }) : super(key: key);

  static const String _wavyLineSvg = '''
<svg width="162" height="22" viewBox="0 0 162 22" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M1 11C27.6667 -2.33333 54.3333 -2.33333 81 11C107.667 24.3333 134.333 24.3333 161 11" stroke="#6B7280" stroke-width="2" stroke-dasharray="4 4"/>
</svg>
''';

  static const String _planeSvg = '''
<svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M21.0949 0.699485C21.5161 0.991367 21.7371 1.49591 21.6579 2.00044L18.9892 19.3466C18.9267 19.751 18.6807 20.1054 18.3221 20.3056C17.9635 20.5057 17.534 20.5308 17.1545 20.3723L12.1675 18.3L9.31126 21.3897C8.94016 21.7942 8.35639 21.9276 7.84352 21.7275C7.33064 21.5273 6.99706 21.0311 6.99706 20.4807V16.9948C6.99706 16.828 7.0596 16.6696 7.17219 16.5487L14.1607 8.92221C14.4025 8.65952 14.3942 8.25505 14.144 8.00487C13.8938 7.75468 13.4893 7.738 13.2266 7.97568L4.7454 15.5104L1.06352 13.6674C0.621528 13.4464 0.337986 13.0044 0.325477 12.5124C0.312968 12.0203 0.571492 11.5617 0.996805 11.3156L19.6772 0.641109C20.1234 0.386755 20.6738 0.411773 21.0949 0.699485Z" fill="#4B5563"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CityThumbnail(city: fromCity, thumbnail: fromThumbnail),
        const SizedBox(width: 8),
        // Center the SVG line and plane vertically with the thumbnails
        SizedBox(
          width: 162,
          height: 64, // Match the thumbnail diameter
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.string(_wavyLineSvg),
                SvgPicture.string(_planeSvg, width: 22, height: 22),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CityThumbnail(city: toCity, thumbnail: toThumbnail),
      ],
    );
  }
}

class _CityThumbnail extends StatelessWidget {
  final String city;
  final String thumbnail;
  const _CityThumbnail({required this.city, required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(thumbnail),
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          city,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
} 