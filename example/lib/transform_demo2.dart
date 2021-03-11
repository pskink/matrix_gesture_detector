import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class TransformDemo2 extends StatefulWidget {
  @override
  _TransformDemo2State createState() => _TransformDemo2State();
}

class _TransformDemo2State extends State<TransformDemo2> {
  Matrix4? matrix;
  late ValueNotifier<Matrix4?> notifier;
  late Boxer boxer;

  @override
  void initState() {
    super.initState();
    matrix = Matrix4.identity();
    notifier = ValueNotifier(matrix);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TransformDemo Demo 2'),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          var width = constraints.biggest.width / 1.5;
          var height = constraints.biggest.height / 2.0;
          var dx = (constraints.biggest.width - width) / 2;
          var dy = (constraints.biggest.height - height) / 2;
          matrix!.leftTranslate(dx, dy);
          boxer = Boxer(Offset.zero & constraints.biggest,
              Rect.fromLTWH(0, 0, width, height));
          return MatrixGestureDetector(
            shouldRotate: false,
            onMatrixUpdate: (m, tm, sm, rm) {
              matrix = MatrixGestureDetector.compose(matrix!, tm, sm, null);
              boxer.clamp(matrix!);
              notifier.value = matrix;
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.topLeft,
              color: Colors.deepPurple,
              child: AnimatedBuilder(
                builder: (ctx, child) {
                  return Transform(
                    transform: matrix!,
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          border: Border.all(
                            color: Colors.black45,
                            width: 20,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      child: Center(
                        child: Text(
                          'you can move & scale me',
                          textAlign: TextAlign.center,
                          style: Theme.of(ctx).textTheme.display1,
                        ),
                      ),
                    ),
                  );
                },
                animation: notifier,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Boxer {
  final Rect bounds;
  final Rect src;
  late Rect dst;

  Boxer(this.bounds, this.src);

  void clamp(Matrix4 m) {
    dst = MatrixUtils.transformRect(m, src);
    if (bounds.left <= dst.left &&
        bounds.top <= dst.top &&
        bounds.right >= dst.right &&
        bounds.bottom >= dst.bottom) {
      // bounds contains dst
      return;
    }

    if (dst.width > bounds.width || dst.height > bounds.height) {
      Rect intersected = dst.intersect(bounds);
      FittedSizes fs = applyBoxFit(BoxFit.contain, dst.size, intersected.size);

      vector.Vector3 t = vector.Vector3.zero();
      intersected = Alignment.center.inscribe(fs.destination, intersected);
      if (dst.width > bounds.width)
        t.y = intersected.top;
      else
        t.x = intersected.left;

      var scale = fs.destination.width / src.width;
      vector.Vector3 s = vector.Vector3(scale, scale, 0);
      m.setFromTranslationRotationScale(t, vector.Quaternion.identity(), s);
      return;
    }

    if (dst.left < bounds.left) {
      m.leftTranslate(bounds.left - dst.left, 0.0);
    }
    if (dst.top < bounds.top) {
      m.leftTranslate(0.0, bounds.top - dst.top);
    }
    if (dst.right > bounds.right) {
      m.leftTranslate(bounds.right - dst.right, 0.0);
    }
    if (dst.bottom > bounds.bottom) {
      m.leftTranslate(0.0, bounds.bottom - dst.bottom);
    }
  }
}
