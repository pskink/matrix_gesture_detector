library matrix_gesture_detector;

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

typedef MatrixGestureDetectorCallback = void Function(Matrix4 matrix);

/// A gesture detector which detects translation, scale and rotation gestures
/// and combines them into [Matrix4] object that can be used by [Transform] widget
/// or by low level [CustomPainter] code. You can customize types of reported
/// gestures by passing [shouldTranslate], [shouldScale] and [shouldRotate]
/// parameters.
///
class MatrixGestureDetector extends StatefulWidget {
  /// [Matrix4] change notification callback
  ///
  final MatrixGestureDetectorCallback onMatrixUpdate;

  /// The [child] contained by this detector.
  ///
  /// {@macro flutter.widgets.child}
  ///
  final Widget child;

  /// Whether to detect translation gestures during the event processing.
  ///
  /// Defaults to true.
  ///
  final bool shouldTranslate;

  /// Whether to detect scale gestures during the event processing.
  ///
  /// Defaults to true.
  ///
  final bool shouldScale;

  /// Whether to detect rotation gestures during the event processing.
  ///
  /// Defaults to true.
  ///
  final bool shouldRotate;

  /// Whether [ClipRect] widget should clip [child] widget.
  ///
  /// Defaults to true.
  ///
  final bool clipChild;

  const MatrixGestureDetector({
    Key key,
    @required this.onMatrixUpdate,
    @required this.child,
    this.shouldTranslate = true,
    this.shouldScale = true,
    this.shouldRotate = true,
    this.clipChild = true,
  })  : assert(onMatrixUpdate != null),
        assert(child != null),
        super(key: key);

  @override
  _MatrixGestureDetectorState createState() => _MatrixGestureDetectorState();
}

class _MatrixGestureDetectorState extends State<MatrixGestureDetector> {
  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    Widget child =
        widget.clipChild ? ClipRect(child: widget.child) : widget.child;
    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: child,
    );
  }

  _ValueUpdater<Offset> translationUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );
  _ValueUpdater<double> rotationUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );
  _ValueUpdater<double> scaleUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal / oldVal,
  );

  void onScaleStart(ScaleStartDetails details) {
    translationUpdater.value = details.focalPoint;
    rotationUpdater.value = double.nan;
    scaleUpdater.value = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    // handle matrix translating
    if (widget.shouldTranslate) {
      Offset translationDelta = translationUpdater.update(details.focalPoint);
      // TODO should we use a Matrix4 here like for _scale and _rotate?
      matrix.leftTranslate(translationDelta.dx, translationDelta.dy);
    }

    RenderBox renderBox = context.findRenderObject();
    Offset focalPoint = renderBox.globalToLocal(details.focalPoint);

    // handle matrix scaling
    if (widget.shouldScale && details.scale != 1.0) {
      double scaleDelta = scaleUpdater.update(details.scale);
      matrix = _scale(scaleDelta, focalPoint.dx, focalPoint.dy) * matrix;
    }

    // handle matrix rotating
    if (widget.shouldRotate && details.rotation != 0.0) {
      if (rotationUpdater.value.isNaN) {
        rotationUpdater.value = details.rotation;
      } else {
        double rotationDelta = rotationUpdater.update(details.rotation);
        matrix = _rotate(rotationDelta, focalPoint.dx, focalPoint.dy) * matrix;
      }
    }

    widget.onMatrixUpdate(Matrix4.copy(matrix));
  }

  Matrix4 _scale(double scale, double px, double py) {
    Matrix4 matrix = Matrix4.diagonal3Values(scale, scale, 1);
    var dx = (1 - scale) * px;
    var dy = (1 - scale) * py;
    matrix.setTranslationRaw(dx, dy, 0.0);
    return matrix;
  }

  Matrix4 _rotate(double angle, double px, double py) {
    Matrix4 matrix = Matrix4.rotationZ(angle);
    var cosa = cos(angle);
    var sina = sin(angle);
    var dx = (1 - cosa) * px + sina * py;
    var dy = (1 - cosa) * py - sina * px;
    matrix.setTranslationRaw(dx, dy, 0.0);
    return matrix;
  }
}

typedef _OnUpdate<T> = T Function(T oldValue, T newValue);

class _ValueUpdater<T> {
  final _OnUpdate<T> onUpdate;
  T value;

  _ValueUpdater({this.onUpdate});

  T update(T newValue) {
    T updated = onUpdate(value, newValue);
    value = newValue;
    return updated;
  }
}
