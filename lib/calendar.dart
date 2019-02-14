import 'package:flutter/material.dart';
import 'package:drink_water/calendar/water_calendar.dart' show CalendarCarousel;

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => new _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          title: const Text(
            'Drink History',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          elevation: 0.0,
          actions: <Widget>[],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          child: CalendarCarousel(
//            current: DateTime.now(),
//            onDayPressed: (DateTime date) {
//              this.setState(() => _currentDate = date);
//            },
            thisMonthDayBorderColor: Colors.grey,
            height: 420.0,
            selectedDateTime: DateTime.now(),
            daysHaveCircularBorder: true,

            /// null for not rendering any border, true for circular border, false for rectangular border
//            markedDatesMap: true,
//          weekendStyle: TextStyle(
//            color: Colors.red,
//          ),
//          weekDays: null, /// for pass null when you do not want to render weekDays
//          headerText: Container( /// Example for rendering custom header
//            child: Text('Custom Header'),
//          ),
          ),
        ));
  }
}
