import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
          primaryColor: Color(0xFFFF6688),
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
      sliderPercent = sliderController._springingPercent;
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

class SliderDebug extends StatelessWidget {
  final double paddingTop;
  final double paddingBottom;
  final double sliderPercent;

  SliderDebug({this.paddingTop, this.paddingBottom, this.sliderPercent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final height = constraints.maxHeight - paddingTop - paddingBottom;

          return Stack(
            children: <Widget>[
              Positioned(
                left: 0.0,
                right: 0.0,
                top: height * (1.0 - sliderPercent) + paddingTop,
                child: Container(
                  height: 2.0,
                  color: Colors.black,
                ),
              )
            ],
          );
        });
  }
}

class SliderDragger extends StatefulWidget {
  final Widget child;
  final double paddingTop;
  final double paddingBottom;
  final SpringySliderController sliderController;

  SliderDragger(
      {this.child, this.sliderController, this.paddingTop, this.paddingBottom});

  @override
  _SliderDraggerState createState() => _SliderDraggerState();
}

class _SliderDraggerState extends State<SliderDragger> {
  double startDragY;
  double startDragPercent;

  void _onPanStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = widget.sliderController.sliderValue;
    final sliderWidth = context.size.width;
    final sliderLeftPosition = (context.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0))
        .dx;
    final dragHorizontalPercent = (details.globalPosition.dx -
        sliderLeftPosition) / sliderWidth;

    widget.sliderController.onDragStart(dragHorizontalPercent);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight =
        context.size.height - widget.paddingTop - widget.paddingBottom;
    final dragPercent = dragDistance / sliderHeight;

    final sliderWidth = context.size.width;
    final sliderLeftPosition = (context.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0))
        .dx;
    final dragHorizontalPercent = (details.globalPosition.dx -
        sliderLeftPosition) / sliderWidth;
    widget.sliderController.draggingPercents =
        Offset(dragHorizontalPercent, startDragPercent + dragPercent);
  }

  void _onPanEnd(DragEndDetails details) {
    startDragY = null;
    startDragPercent = null;
    widget.sliderController.onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}

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

class SpringySliderController extends ChangeNotifier {
  final SpringDescription sliderSpring = new SpringDescription(
    mass: 1.0,
    stiffness: 1000.0,
    damping: 30.0,
  );

  final SpringDescription crestSpring = SpringDescription(
      mass: 1.0,
      stiffness: 5.0,
      damping: 0.5
  );

  final TickerProvider _vsync;
  SpringySliderState _state = SpringySliderState.idle;
  double _sliderPercent;
  double _draggingPercent;
  double _draggingHorizontalPercent;
  double _springStartPercent;
  double _springEndPercent;
  double _springingPercent;
  SpringSimulation _sliderSpringSimulation;
  double _crestSpringingStartPercent;
  double _crestSpringingEndPercent;
  double _crestSpringingPercent;
  SpringSimulation _crestSpringSimulation;
  Ticker _springTicker;
  double _springTime;

  SpringySliderController({
    double sliderPercent = 0.0,
    vsync,
  })
      : _vsync = vsync,
        _sliderPercent = sliderPercent;

  @override
  void dispose() {
    if (_springTicker != null) {
      _springTicker.dispose();
    }
    super.dispose();
  }

  SpringySliderState get state => _state;

  double get sliderValue => _sliderPercent;

  set sliderValue(double newValue) {
    _sliderPercent = newValue;
    notifyListeners();
  }

  double get draggingPercent => _draggingPercent;

  double get draggingHorizontalPercent => _draggingHorizontalPercent;

  set draggingPercents(Offset draggingPercents) {
    _draggingHorizontalPercent = draggingPercents.dx;
    _draggingPercent = draggingPercents.dy;
    notifyListeners();
  }

  void onDragStart(double draggingHorizontalPercent) {
    if (_springTicker != null) {
      _springTicker
        ..stop()
        ..dispose();
    }
    _state = SpringySliderState.dragging;
    _draggingPercent = _sliderPercent;
    _draggingHorizontalPercent = draggingHorizontalPercent;
    notifyListeners();
  }

  void onDragEnd() {
    _state = SpringySliderState.springing;
    _springingPercent = _sliderPercent;
    _springStartPercent = _sliderPercent;
    _springEndPercent = _draggingPercent.clamp(0.0, 1.0);

    _crestSpringingPercent = draggingPercent;
    _crestSpringingStartPercent = _draggingPercent;
    _crestSpringingEndPercent = _springStartPercent;

    debugPrint(
        'springEndPercent = $_springEndPercent draggingPercent = $_draggingPercent');
//    draggingPercents = null;
    _sliderPercent = _springEndPercent;
    _startSpringing();
    notifyListeners();
  }

  void _startSpringing() {
    if (_springStartPercent == _springEndPercent) {
      _state = SpringySliderState.idle;
      notifyListeners();
      return;
    }

    _sliderSpringSimulation = SpringSimulation(
        sliderSpring, _springStartPercent, _springEndPercent, 0.0);

    final crestSpringNormal = (_crestSpringingEndPercent -
        _crestSpringingStartPercent) /
        (_crestSpringingEndPercent - _crestSpringingStartPercent).abs();
    _crestSpringSimulation = SpringSimulation(
        crestSpring, _crestSpringingStartPercent, _crestSpringingEndPercent,
        0.5 * crestSpringNormal);

    _springTime = 0.0;
    _springTicker = _vsync.createTicker(_springTick)
      ..start();
    notifyListeners();
  }

  void _springTick(Duration deltaTime) {
    final lastFrameTime = deltaTime.inMilliseconds.toDouble() / 1000.0;
    _springTime += lastFrameTime;
    _springingPercent = _sliderSpringSimulation.x(_springTime);

    _crestSpringingPercent = _crestSpringSimulation.x(lastFrameTime);
    _crestSpringSimulation = new SpringSimulation(
        crestSpring, _crestSpringingPercent, _springingPercent,
        _crestSpringSimulation.dx(lastFrameTime));

    if (_sliderSpringSimulation.isDone(_springTime) &&
        _crestSpringSimulation.isDone(lastFrameTime)) {
      _springTicker
        ..stop()
        ..dispose();
      _springTicker = null;
      _state = SpringySliderState.idle;
    }
    notifyListeners();
  }

  double get springingPercent => _springingPercent;


  double get crestSpringingPercent => _crestSpringingPercent;
}

enum SpringySliderState { idle, dragging, springing }
