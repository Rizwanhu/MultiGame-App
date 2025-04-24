import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final VoidCallback? onPressed; // Fix: Use VoidCallback? instead of Function?
  final Icon? icon;

  const ControlButton({super.key, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        width: 50.0,
        height: 50.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            elevation: 0.0, // 'this.' is optional here
            onPressed: onPressed,
            child: icon, // Fix: Now correctly typed
          ),
        ),
      ),
    );
  }
}
