import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:drink_water/slider/SpringySlider.dart';
import 'calendar.dart';
import 'dart:io' show Platform;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          primaryColor: Color(0xFF73B6FE),
          scaffoldBackgroundColor: Colors.white),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: const Text(
            'Drink Water',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.blue,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              onPressed: _openCalendarScreen,
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Container(
                    child: SpringySlider(
                        markCount: 12,
                        positiveColor: Theme.of(context).primaryColor,
                        negativeColor:
                            Theme.of(context).scaffoldBackgroundColor)))
          ],
        ));
  }

  void _openCalendarScreen() {
    PageRoute route = Platform.isAndroid ? MaterialPageRoute(builder: (context) => CalendarPage()) : CupertinoPageRoute(builder: (context) => CalendarPage());
      Navigator.push( context, route
    );
  }
}
