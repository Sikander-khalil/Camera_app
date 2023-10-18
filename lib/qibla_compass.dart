import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  double? heading = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterCompass.events!.listen((event) {
      heading = event.heading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("COMPASS APP"),
      ),
      body: Column(
        children: [
          Text(
            "${heading!.ceil()}",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: EdgeInsets.all(18.0),
            child: Stack(alignment: Alignment.center, children: [
              Image.asset("assets/qibla.png"),
              Transform.rotate(
                angle: ((heading ?? 0) * (pi / 180) * -1),
                child: Image.asset(
                  "assets/compass",
                  scale: 1.1,
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
