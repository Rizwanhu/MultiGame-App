import 'package:flutter/material.dart';
import 'home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   // primaryColor: Colors.black,
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: Colors.black,
      //     elevation: 0,
      //     iconTheme: IconThemeData(color: Colors.white),
      //   ),
      // ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Tic Tac Toe', style: TextStyle(color: Colors.white)),
        ),
        body: HomePage(),
      ),
    );
  }
}
