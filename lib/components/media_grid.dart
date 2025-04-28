import 'package:flutter/material.dart';

class DiagonalMediaGrid extends StatefulWidget {
  const DiagonalMediaGrid({super.key});

  @override
  State<DiagonalMediaGrid> createState() => _DiagonalMediaGridState();
}

class _DiagonalMediaGridState extends State<DiagonalMediaGrid> {
  Widget _buildMediaClip(int index, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipPath(
          clipper: _DiagonalClipper(index),
          child: child, // ❌ Removed internal border to avoid gaps
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced from 16.0 to 8.0
      child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 4), // Changed to black and increased width
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge, // ✅ Clips children to rounded border
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            _buildMediaClip(
              0,
              Image.asset('assets/images/island.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            _buildMediaClip(
              1,
              Image.asset('assets/images/coin.gif', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            _buildMediaClip(
              2,
              Image.asset('assets/images/squid1.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
          ],
        ),
      ),
),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  final int index;
  _DiagonalClipper(this.index);

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    switch (index) {
      case 0:
        // Left diagonal section
        path.moveTo(0, 0);
        path.lineTo(w * 0.4, 0);
        path.lineTo(w * 0.15, h);
        path.lineTo(0, h);
        break;
      case 1:
        // Middle diagonal section
        path.moveTo(w * 0.4, 0);
        path.lineTo(w * 0.8, 0);
        path.lineTo(w * 0.55, h);
        path.lineTo(w * 0.15, h);
        break;
      case 2:
        // Right diagonal section
        path.moveTo(w * 0.8, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h);
        path.lineTo(w * 0.55, h);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
