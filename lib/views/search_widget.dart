import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'package:Markovid/provider/fokontany_provider.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key key, @required this.goToLocation}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
  final Function(LatLng) goToLocation;
}

class _SearchWidgetState extends State<SearchWidget> {
  FocusNode focus;
  double _opacity = 0;
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
                      onPressed: () {},
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
