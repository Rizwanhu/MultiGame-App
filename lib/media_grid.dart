import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart' // Commented out video player

class DiagonalMediaGrid extends StatefulWidget {
  const DiagonalMediaGrid({super.key});

  @override
  State<DiagonalMediaGrid> createState() => _DiagonalMediaGridState();
}

class _DiagonalMediaGridState extends State<DiagonalMediaGrid> {
  // Removed video controller and initialization code

  Widget _buildMediaClip(int index, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipPath(
          clipper: _DiagonalClipper(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 6),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        children: [
          // Image 1
          _buildMediaClip(
            0,
            Image.asset('assets/images/island.jpg', fit: BoxFit.cover),
          ),
          // GIF
          _buildMediaClip(
            1,
            Image.asset('assets/images/coin.gif', fit: BoxFit.cover),
          ),
          // Commented out Video section
          /*_buildMediaClip(
            2,
            _isInitialized 
              ? VideoPlayer(_controller)
              : const Center(child: CircularProgressIndicator()),
          ),*/
          // Image 2
          _buildMediaClip(
            2, // Changed from 3 to 2 since we removed video section
            Image.asset('assets/images/squid.png', fit: BoxFit.cover),
          ),
        ],
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
        path.moveTo(0, 0);
        path.lineTo(w * 0.4, 0);
        path.lineTo(w * 0.2, h);
        path.lineTo(0, h);
        break;
      case 1:
        path.moveTo(w * 0.4, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h * 0.4);
        path.lineTo(w * 0.2, h);
        break;
      case 2:
        path.moveTo(0, h);
        path.lineTo(w * 0.2, h);
        path.lineTo(w * 0.6, h);
        path.lineTo(w * 0.4, h);
        break;
      case 3:
        path.moveTo(w * 0.6, h);
        path.lineTo(w, h);
        path.lineTo(w, h * 0.4);
        path.lineTo(w * 0.4, h);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
