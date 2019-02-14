import 'dart:math';
import 'package:drink_water/slider/SpringySliderController.dart';
import 'package:flutter/material.dart';

class SliderClipper extends CustomClipper<Path> {
  final double paddingTop;
  final double paddingBottom;
  final SpringySliderController sliderController;

  SliderClipper({this.paddingTop, this.paddingBottom, this.sliderController});

  @override
  Path getClip(Size size) {
    switch (sliderController.state) {
      case SpringySliderState.idle:
        return _clipIdle(size);
      case SpringySliderState.dragging:
        return _clipDragging(size);
      case SpringySliderState.springing:
        return _clipSpringing(size);
    }
  }

  Path _clipIdle(Size size) {
    Path rect = Path();
    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingBottom) - top;
    final percentFromBottom = 1.0 - sliderController.sliderValue;
    rect.addRect(Rect.fromLTRB(
        0.0, top + (percentFromBottom * height), size.width, bottom));
    return rect;
  }

  Path _clipDragging(Size size) {
    Path compositePath = new Path();

    final top = paddingTop;
    final bottom = size.height - paddingBottom;
    final height = bottom - top;
    final basePercentFromBottom = 1.0 - sliderController.sliderValue;
    final dragPercentFromBottom = 1.0 - sliderController.draggingPercent;

    final baseY = top + (basePercentFromBottom * height);
    final leftX = -0.15 * size.width;
    final leftPoint = Point(leftX, baseY);
    final rightX = 1.15 * size.width;
    final rightPoint = Point(rightX, baseY);

    final dragX = sliderController.draggingHorizontalPercent * size.width;
    final dragY = top + (dragPercentFromBottom * height);
    final crestPoint = Point(dragX, dragY.clamp(top, bottom));

    double excessDrag = 0.0;
    if (sliderController.draggingPercent < 0.0) {
      excessDrag = sliderController.draggingPercent;
    } else if (sliderController.draggingPercent > 1.0) {
      excessDrag = sliderController.draggingPercent - 1.0;
    }
    final baseControlPointWidth = 150.0;
    final thickeningFactor = excessDrag * height * 0.05;
    final controlPointWidth = (200.0 * thickeningFactor).abs() + baseControlPointWidth;

    final rect = new Path();
    rect.moveTo(leftPoint.x, leftPoint.y);
    rect.lineTo(rightPoint.x, rightPoint.y);
    rect.lineTo(rightPoint.x, size.height);
    rect.lineTo(leftPoint.x, size.height);
    rect.lineTo(leftPoint.x, leftPoint.y);
    rect.close();

    compositePath.addPath(rect, const Offset(0.0, 0.0));

    final curve = new Path();
    curve.moveTo(crestPoint.x, crestPoint.y);
    curve.quadraticBezierTo(
      crestPoint.x - controlPointWidth,
      crestPoint.y,
      leftPoint.x,
      leftPoint.y,
    );

    curve.moveTo(rightPoint.x, rightPoint.y);
    curve.quadraticBezierTo(
      crestPoint.x + controlPointWidth,
      crestPoint.y,
      crestPoint.x,
      crestPoint.y,
    );


    curve.lineTo(leftPoint.x, leftPoint.y);
    curve.close();

    if (dragPercentFromBottom > basePercentFromBottom) {
      compositePath.fillType = PathFillType.evenOdd;
    }

    compositePath.addPath(curve, const Offset(0.0, 0.0));

    return compositePath;
  }

  Path _clipSpringing(Size size) {
    Path compositePath = Path();
    final top = paddingTop;
    final bottom = size.height - paddingBottom;
    final height = bottom - top;
    final basePercentFromBottom = 1.0 - sliderController.springingPercent;
    final crestSpringingPercentFromBottom = 1.0 -
        sliderController.crestSpringingPercent;

    final baseY = top + (basePercentFromBottom * height);
    final leftX = -0.85 * size.width;
    final leftPoint = Point(leftX, baseY);

    final centerX = 0.15 * size.width;
    final centerPoint = Point(centerX, baseY);

    final rightX = 1.15 * size.width;
    final rightPoint = Point(rightX, baseY);
    final crestY = top + (crestSpringingPercentFromBottom * height);
    final crestPoint = Point((rightX - centerX) / 2 + centerX, crestY);
    final troughY = baseY + (baseY - crestY);
    final troughPoint = Point((centerX - leftX) / 2 + leftX, troughY);



    final controlPointWidth = 100;
    final rect = Path();
    rect.moveTo(leftPoint.x, leftPoint.y);
    rect.lineTo(rightPoint.x, rightPoint.y);
    rect.lineTo(rightPoint.x, size.height);
    rect.lineTo(leftPoint.x, size.height);
    rect.lineTo(leftPoint.x, leftPoint.y);
    rect.close();

    compositePath.addPath(rect, Offset(0.0, 0.0));

    final rightCurve = Path();
    rightCurve.moveTo(crestPoint.x, crestPoint.y);
    rightCurve.quadraticBezierTo(
        crestPoint.x - controlPointWidth, crestPoint.y, centerPoint.x,
        centerPoint.y);

    rightCurve.moveTo(crestPoint.x, crestPoint.y);
    rightCurve.quadraticBezierTo(
        crestPoint.x + controlPointWidth, crestPoint.y, rightPoint.x,
        rightPoint.y);
    rightCurve.lineTo(centerPoint.x, centerPoint.y);
    rightCurve.close();

    if (crestSpringingPercentFromBottom > basePercentFromBottom) {
      compositePath.fillType = PathFillType.evenOdd;
    }

    compositePath.addPath(rightCurve, const Offset(0.0, 0.0));

    final leftCurve = Path();

    leftCurve.moveTo(troughPoint.x, troughPoint.y);
    leftCurve.quadraticBezierTo(
        troughPoint.x - controlPointWidth,
        troughPoint.y,
        leftPoint.x,
        leftPoint.y);

//    leftCurve.moveTo(troughPoint.x, troughPoint.y);
//    leftCurve.quadraticBezierTo(
//        troughPoint.x + controlPointWidth,
//        troughPoint.y,
//        centerPoint.x,
//        centerPoint.y);

    leftCurve.moveTo(centerPoint.x, centerPoint.y);

    leftCurve.quadraticBezierTo(
        troughPoint.x + controlPointWidth,
        troughPoint.y,
        troughPoint.x,
        troughPoint.y);

    leftCurve.lineTo(leftPoint.x, leftPoint.y);
    leftCurve.close();

    if (crestSpringingPercentFromBottom < basePercentFromBottom) {
      compositePath.fillType = PathFillType.evenOdd;
    }

    compositePath.addPath(leftCurve, const Offset(0.0, 0.0));

    return compositePath;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}