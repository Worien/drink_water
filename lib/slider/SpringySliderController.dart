import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:developer';




class SpringySliderController extends ChangeNotifier {
  final SpringDescription sliderSpring = new SpringDescription(
    mass: 1.0,
    stiffness: 1000.0,
    damping: 30.0,
  );

  final SpringDescription crestSpring = SpringDescription(
      mass: 3.0,
      stiffness: 5.0,
      damping: 0.2
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

  void saveWaterPercentForCurrentDay(){
    
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
    debugPrint('time: $_springTime');

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
