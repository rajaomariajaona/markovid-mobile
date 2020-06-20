import 'package:Markovid/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'package:Markovid/provider/fokontany_provider.dart';

class SearchWidgetWeb extends StatefulWidget {
  const SearchWidgetWeb(
      {Key key, @required this.goToLocation, @required this.openDrawer})
      : super(key: key);

  @override
  _SearchWidgetWebState createState() => _SearchWidgetWebState();
  final Function(LatLng) goToLocation;
  final Function() openDrawer;
}

class _SearchWidgetWebState extends State<SearchWidgetWeb> {
  FocusNode focus;
  double _opacity = 0;

  int casConfirme;
  int casSuspect;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    focus = FocusNode();
    this.focus.addListener(() {
      if (!focus.hasFocus) _opacity = 0;
      setState(() {
        _opacity = 1;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned(
        top: 10,
        right: 15,
        left: 15,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: Card(
                margin: EdgeInsets.zero,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      splashColor: Colors.grey,
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        widget.openDrawer();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: focus,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            hintText: "Rechercher..."),
                        onChanged: (String cr) async {
                          await context
                              .read<FokontanyProvider>()
                              .getFokontany(cr);
                        },
                        onEditingComplete: () {},
                      ),
                    ),
                    if (focus.hasFocus)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            focus.unfocus();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      if (focus.hasFocus)
        Positioned.fill(
          bottom: 15,
          top: 70,
          left: 15,
          right: 15,
          child: AnimatedOpacity(
            curve: Curves.easeIn,
            duration: Duration(seconds: 3800),
            opacity: _opacity,
            child: Card(
              child: Consumer<FokontanyProvider>(
                builder: (ctx, fkt, _) => Container(
                  color: Colors.white,
                  child: fkt.loading
                      ? Center(
                          child: SpinKitDoubleBounce(
                          color: Colors.teal,
                        ))
                      : fkt.recherche?.isEmpty ?? true
                          ? Container()
                          : ListView.separated(
                              itemCount: fkt.recherche.length,
                              separatorBuilder: (ctx, i) => Divider(),
                              itemBuilder: (ctx, i) => ListTile(
                                title: Text(
                                    "${fkt.recherche[i].nom}, ${fkt.recherche[i].province}"),
                                onTap: () {
                                  widget.goToLocation(fkt.recherche[i].centre);
                                  focus.unfocus();
                                  showDialog(
                                    context: context,
                                    builder: (c) => Dialog(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        child: SingleChildScrollView(
                                          child: Form(
                                            key: formKey,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            "cas suspect"),
                                                    initialValue: fkt
                                                        .recherche[i].casSuspect
                                                        .toString(),
                                                    onSaved: (String data) {
                                                      casSuspect =
                                                          int.parse(data);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            "cas confirme"),
                                                    initialValue: fkt
                                                        .recherche[i]
                                                        .casConfirme
                                                        .toString(),
                                                    onSaved: (String data) {
                                                      casConfirme =
                                                          int.parse(data);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                RaisedButton(
                                                  child: Text("Enregistrer"),
                                                  onPressed: () async {
                                                    if (formKey.currentState
                                                        .validate()) {
                                                      formKey.currentState
                                                          .save();
                                                      Dio dio =
                                                          await RestRequest()
                                                              .getDioInstance();
                                                      dio.patch(
                                                          "/${fkt.recherche[i].id}/cas",
                                                          data: {
                                                            "casConfirme":
                                                                casConfirme
                                                                    .toString(),
                                                            "casSuspect":
                                                                casSuspect
                                                                    .toString()
                                                          });
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ),
          ),
        )
    ]);
  }
}
