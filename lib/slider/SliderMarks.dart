import 'package:drink_water/slider/SpringySliderController.dart';
import 'package:flutter/material.dart';
import 'package:drink_water/slider/SliderClipper.dart';

class SliderGoo extends StatelessWidget {
  final Widget child;
  final double paddingTop;
  final double paddingBottom;
  final SpringySliderController sliderController;

  SliderGoo(
      {this.child, this.paddingTop, this.paddingBottom, this.sliderController});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
        clipBehavior: Clip.antiAlias,
        clipper: SliderClipper(

            sliderController: sliderController,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom),
        child: child);
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color markColor;
  final Color backgroundColor;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks({this.markCount,
    this.markColor,
    this.paddingTop,
    this.paddingBottom,
    this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(),
      painter: SliderMarksPainter(
          markCount: markCount,
          markColor: markColor,
          backgroundColor: backgroundColor,
          markThickness: 2.0,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 15.0;
  final double paddingRight = 20.0;

  final int markCount;
  final Color markColor;
  final Color backgroundColor;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final Paint markPaint;
  final Paint backgroundPaint;

  SliderMarksPainter({this.markCount,
    this.markColor,
    this.markThickness,
    this.paddingTop,
    this.paddingBottom,
    this.backgroundColor})
      : markPaint = Paint()
    ..color = markColor
    ..strokeWidth = markThickness
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round,
        backgroundPaint = new Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawRect(rect, backgroundPaint);
    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);
    for (int i = 0; i < markCount; ++i) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1) {
        markWidth = largeMarkWidth;
      } else if (i == 1 || i == markCount - 2) {
        markWidth = (smallMarkWidth + largeMarkWidth) / 2;
      }
      final markY = i * gap + paddingTop;
      canvas.drawLine(Offset(size.width - markWidth - paddingRight, markY),
          Offset(size.width - paddingRight, markY), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}