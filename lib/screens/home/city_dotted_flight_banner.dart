import 'package:flutter/material.dart';

class CityDottedFlightBanner extends StatelessWidget {
  final String fromCity;
  final String fromThumbnail;
  final String toCity;
  final String toThumbnail;

  const CityDottedFlightBanner({
    Key? key,
    required this.fromCity,
    required this.fromThumbnail,
    required this.toCity,
    required this.toThumbnail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _CityThumbnailBox(city: fromCity, thumbnail: fromThumbnail),
        Expanded(
          child: SizedBox(
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dotted line
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DottedLinePainter(),
                  ),
                ),
                // Plane icon in circle
                Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.airplanemode_active,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _CityThumbnailBox(city: toCity, thumbnail: toThumbnail),
      ],
    );
  }
}

class _CityThumbnailBox extends StatelessWidget {
  final String city;
  final String thumbnail;
  const _CityThumbnailBox({required this.city, required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return Column(
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

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 6;
    const double dashSpace = 4;
    double startX = 0;
    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 2;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 