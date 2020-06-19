import 'package:Markovid/provider/fokontany_provider.dart';
import 'package:Markovid/provider/socket_provider.dart';
import 'package:Markovid/views/map_page.dart';
import 'package:Markovid/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => FokontanyProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SocketProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Markovid',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: kIsWeb? "/map":"/",
        routes: <String, Widget Function(BuildContext)>{
          "/": (ctx) => SplashScreen(),
          "/map": (ctx) => MapPage()
        },
      ),
    );
  }
}
