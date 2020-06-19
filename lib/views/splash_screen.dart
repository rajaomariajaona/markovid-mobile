import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

enum TtsState { playing, stopped, paused, continued }

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  FlutterTts flutterTts;
  final String language = "fr-FR";
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.8;
  AnimationController controller;
  Animation<double> sizeAnim;
  String _newVoiceText = "Bienvenue dans Markovid";

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    sizeAnim = Tween<double>(begin: 0.9, end: 1.1).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    initTts();
    _speakAndPush();
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage(language);

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Stopped");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speakAndPush() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height / 10,
            ),
            Center(
                child: Image.asset(
              "assets/logo.png",
              width: size.width * (2 / 3),
            )),
            SizedBox(
              height: size.height / 20,
            ),
            Text(
              "Markovid",
              style: GoogleFonts.deliusUnicase(
                color: Colors.teal,
                fontSize: size.height / 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(
              flex: 2,
            ),
            if (ttsState == TtsState.playing)
              SpinKitCircle(
                color: Colors.teal,
                size: size.width / 7,
              )
            else
              GestureDetector(
                child: Container(
                  width: (size.width / 8) * sizeAnim.value,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]),
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Center(child: Icon(Icons.expand_more))),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed("/map");
                },
              ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
