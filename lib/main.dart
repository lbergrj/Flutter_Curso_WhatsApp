import 'package:flutter/material.dart';
import 'package:whatsapp/screens/route_generator.dart';
import 'package:whatsapp/screens/screen_home.dart';
import 'dart:io';

final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff075e54),
    accentColor: Color(0xff25d366));

final ThemeData temaIOS = ThemeData(
    primaryColor: Colors.grey[200],
    accentColor: Color(0xff25d366));

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScreenHome(),
    theme: Platform.isIOS
    ? temaIOS
    : temaPadrao,

    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
