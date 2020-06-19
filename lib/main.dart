import 'package:Markovid/provider/fokontany_provider.dart';
import 'package:Markovid/views/map_page.dart';
import 'package:Markovid/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => FokontanyProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Markovid',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: "/",
        routes: <String, Widget Function(BuildContext)>{
          "/": (ctx) => SplashScreen(),
          "/map": (ctx) => MapPage()
        },
      ),
    );
  }
}
