import 'package:drink_water/slider/SpringySliderController.dart';
import 'package:flutter/material.dart';

class SliderPoints extends StatelessWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;

  SliderPoints({this.sliderController, this.paddingTop, this.paddingBottom});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double sliderPercent = sliderController.sliderValue;
          if (sliderController.state == SpringySliderState.dragging) {
            sliderPercent = sliderController.draggingPercent.clamp(0.0, 1.0);
          }

          final height = constraints.maxHeight - paddingTop - paddingBottom;
          final sliderY = height * (1 - sliderPercent) + paddingTop;
          final pointsYouNeeedPercent = 1.0 - sliderPercent;
          final pointsYouNeed = (100 * pointsYouNeeedPercent).round();
          final pointsYouHavePercent = sliderPercent;
          final pointsYouHave = (100 - pointsYouNeed);
          return Stack(
            children: <Widget>[
              Positioned(
                  left: 30.0,
                  top: sliderY - 10.0 - (40.0 * pointsYouNeeedPercent),
                  child: FractionalTranslation(
                      translation: Offset(0.0, -1.0),
                      child: Points(
                        points: pointsYouNeed,
                        isAboveTheSlider: true,
                        isPointsYouNeed: true,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ))),
              Positioned(
                  left: 30.0,
                  top: sliderY + 10.0 + (40.0 * pointsYouHavePercent),
                  child: Points(
                    points: pointsYouHave,
                    isAboveTheSlider: false,
                    isPointsYouNeed: false,
                    color: Theme
                        .of(context)
                        .scaffoldBackgroundColor,
                  ))
            ],
          );
        });
  }
}

class Points extends StatelessWidget {
  final int points;
  final bool isAboveTheSlider;
  final bool isPointsYouNeed;
  final Color color;

  const Points(
      {this.points, this.isAboveTheSlider, this.isPointsYouNeed, this.color});

  @override
  Widget build(BuildContext context) {
    final percent = points / 100;
    final pointsTextSize = 50 + (50 * percent);

    return Row(
      crossAxisAlignment:
      isAboveTheSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        FractionalTranslation(
          translation: Offset(-0.05 * percent, isAboveTheSlider ? 0.18 : -0.18),
          child: Text(
            '$points',
            style: TextStyle(fontSize: pointsTextSize, color: color),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  bottom: 4.0,
                ),
                child: Text(
                  'POINTS',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
              Text(
                isPointsYouNeed ? 'YOU NEED' : 'YOU HAVE',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              )
            ],
          ),
        )
      ],
    );
  }
}