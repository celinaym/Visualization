import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'pages/home/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bike Cluster Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 92, 99, 1)),
        primaryColor: Color.fromRGBO(0, 92, 99, 1),
        primaryColorDark: Color.fromRGBO(0, 56, 64, 1),
        primaryColorLight: Color.fromRGBO(76, 138, 143, 1),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(0, 92, 99, 1), // Primary color for buttons
          textTheme: ButtonTextTheme.primary,
        ),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory, // Disable splash effect
      ),
      home: HomePage(),
    );
  }
}
