import 'package:Markovid/provider/fokontany_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height / 20,
          ),
          Center(
              child: Image.asset(
            "assets/logo.png",
            width: size.width * (1 / 3),
          )),
          SizedBox(
            height: size.height / 20,
          ),
          Text(
            "Markovid",
            style: GoogleFonts.deliusUnicase(
              color: Colors.teal,
              fontSize: size.height / 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: size.height / 20,
          ),
          Divider(),
          SizedBox(
            height: size.height / 20,
          ),
          Text(
            "A PROPOS\n",
            style: TextStyle(
                fontSize: size.height / 30, fontWeight: FontWeight.bold),
          ),
          Text(
            "Application permettant de situer les zones risquées dans le cadre du COVID-19\n\n",
            style: TextStyle(),
            textAlign: TextAlign.center,
          ),
          Text(
            "AUTEUR\n",
            style: TextStyle(
                fontSize: size.height / 30, fontWeight: FontWeight.bold),
          ),
          Text(
            "RAJAOMARIA Jaona",
            style: TextStyle(),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          RaisedButton(onPressed: () {
            context.read<FokontanyProvider>().fetchZone();
          })
        ],
      ),
    );
  }
}
