import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon? icon;
  final String? tag; // Add tag parameter

  const ControlButton({
    super.key, 
    this.onPressed, 
    this.icon,
    this.tag, // Add tag to constructor
  });

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
            elevation: 0.0,
            onPressed: onPressed,
            child: icon,
            heroTag: tag ?? UniqueKey().toString(), // Add unique hero tag
          ),
        ),
      ),
    );
  }
}
