import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback resetCallback;
  final String resetText;

  CustomDialog(this.title, this.content, this.resetCallback,
      [this.resetText = "Reset"]);
      
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        // Reset button
        TextButton(
          onPressed: () {
            // Close dialog first, then call reset
            Navigator.of(context).pop();
            resetCallback();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(resetText),
        ),
        
        // Back button
        TextButton(
          onPressed: () {
            // Close the dialog first
            Navigator.of(context).pop();
            
            // Navigate back to previous screen
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text("Exit"),
        ),
      ],
    );
  }
}
