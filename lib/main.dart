import 'package:flutter/material.dart';
import 'SpringySlider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          primaryColor: Color(0x73B6FE),
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
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Container(
                    child: SpringySlider(
                        markCount: 12,
                        positiveColor: Theme
                            .of(context)
                            .primaryColor,
                        negativeColor:
                        Theme
                            .of(context)
                            .scaffoldBackgroundColor)))
          ],
        ));
  }
}














