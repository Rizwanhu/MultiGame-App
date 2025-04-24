import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  final int? posX, posY;
  final int? size;
  final Color color;
  final bool isAnimated;

  const Piece({
    super.key,
    this.posX,
    this.posY,
    this.size,
    this.color = const Color(0XFFBF3100),
    this.isAnimated = false,
  });

  @override
  _PieceState createState() => _PieceState();
}

class _PieceState extends State<Piece> with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // ✅ FIXED: Add 'late'

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      lowerBound: 0.25,
      upperBound: 1.0,
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (widget.posX ?? 0).toDouble(), // ✅ FIXED: Handle null with '??'
      top: (widget.posY ?? 0).toDouble(),  // ✅ FIXED: Handle null with '??'
      child: Opacity(
        opacity: widget.isAnimated ? _animationController.value : 1.0,
        child: Container(
          width: (widget.size ?? 50).toDouble(),  // ✅ FIXED: Handle null with '??'
          height: (widget.size ?? 50).toDouble(), // ✅ FIXED: Handle null with '??'
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.all(
              Radius.circular((widget.size ?? 50).toDouble()), // ✅ FIXED: Handle null with '??'
            ),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
        ),
      ),
    );
  }
}
