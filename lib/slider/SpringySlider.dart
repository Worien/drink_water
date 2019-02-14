import 'package:drink_water/slider/SpringySliderController.dart';
import 'package:drink_water/slider/SliderPoints.dart';
import 'package:flutter/material.dart';
import 'package:drink_water/slider/SliderMarks.dart';
import 'package:drink_water/slider/SliderDragger.dart';



class SpringySlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringySlider({this.markCount, this.positiveColor, this.negativeColor});

  @override
  _SpringySliderState createState() => _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider>
    with TickerProviderStateMixin {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;

  SpringySliderController sliderController;

  @override
  void initState() {
    super.initState();
    sliderController = SpringySliderController(sliderPercent: 0.5, vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    double sliderPercent = sliderController.sliderValue;
    if (sliderController.state == SpringySliderState.springing) {
      sliderPercent = sliderController.springingPercent;
    }
    return SliderDragger(
      sliderController: sliderController,
      paddingBottom: paddingBottom,
      paddingTop: paddingTop,
      child: Stack(
        children: <Widget>[
          SliderMarks(
              markCount: widget.markCount,
              markColor: widget.positiveColor,
              paddingTop: paddingTop,
              backgroundColor: widget.negativeColor,
              paddingBottom: paddingBottom),
          SliderGoo(
            sliderController: sliderController,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
            child: SliderMarks(
                markCount: widget.markCount,
                markColor: widget.negativeColor,
                paddingTop: paddingTop,
                backgroundColor: widget.positiveColor,
                paddingBottom: paddingBottom),
          ),
          SliderPoints(
              sliderController: sliderController,
              paddingTop: paddingTop,
              paddingBottom: paddingBottom),
//          SliderDebug(
//              sliderPercent:
//              sliderController.state == SpringySliderState.dragging
//                  ? sliderController.draggingPercent
//                  : sliderPercent,
//              paddingTop: paddingTop,
//              paddingBottom: paddingBottom),
        ],
      ),
    );
  }
}