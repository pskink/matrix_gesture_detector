import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class TransformDemo4 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TransformDemo4State();
}

class TransformDemo4State extends State<TransformDemo4>
    with TickerProviderStateMixin {
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  bool shouldScale = true;
  bool shouldRotate = true;
  AnimationController controller;

  Alignment focalPoint = Alignment.center;

  Animation<Alignment> focalPointAnimation;
  List items = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ]
      .map(
        (alignment) => DropdownMenuItem<Alignment>(
              value: alignment,
              child: Text(
                alignment.toString(),
              ),
            ),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    focalPointAnimation = makeFocalPointAnimation(focalPoint, focalPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Transform Demo 4'),
      ),
      body: Column(
        children: makeControls() + makeMainWidget(getLabel()),
      ),
    );
  }

  String getLabel() {
    String prefix = 'use your fingers to ';
    if (shouldRotate && shouldScale) return prefix + 'rotate / scale';
    if (shouldRotate) return prefix + 'rotate';
    if (shouldScale) return prefix + 'scale';
    return 'you have to select at least one checkbox above';
  }

  Animation<Alignment> makeFocalPointAnimation(Alignment begin, Alignment end) {
    return controller.drive(AlignmentTween(begin: begin, end: end));
  }

  List<Widget> makeControls() => [
        ListTile(
          title: Text('focal point'),
          trailing: DropdownButton(
            onChanged: (value) {
              setState(() {
                focalPointAnimation =
                    makeFocalPointAnimation(focalPointAnimation.value, value);
                focalPoint = value;
                controller.forward(from: 0.0);
              });
            },
            value: focalPoint,
            items: items,
          ),
        ),
        CheckboxListTile(
          value: shouldScale,
          onChanged: (bool value) {
            setState(() {
              shouldScale = value;
            });
          },
          title: Text('scale'),
        ),
        CheckboxListTile(
          value: shouldRotate,
          onChanged: (bool value) {
            setState(() {
              shouldRotate = value;
            });
          },
          title: Text('rotate'),
        ),
      ];

  List<Widget> makeMainWidget(String label) => [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: MatrixGestureDetector(
              onMatrixUpdate: (m, tm, sm, rm) {
                notifier.value = m;
              },
              shouldTranslate: false,
              shouldScale: shouldScale,
              shouldRotate: shouldRotate,
              focalPointAlignment: focalPoint,
              clipChild: false,
              child: CustomPaint(
                foregroundPainter: FocalPointPainter(focalPointAnimation),
                child: AnimatedBuilder(
                  animation: notifier,
                  builder: (ctx, child) {
                    return Transform(
                      transform: notifier.value,
                      child: GridPaper(
                        color: Color(0xaa0000ff),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 4.0, color: Colors.blue),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          child: Container(
                            decoration: FlutterLogoDecoration(),
                            padding: EdgeInsets.all(32),
                            alignment: Alignment(0, -0.5),
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.display2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        )
      ];
}

class FocalPointPainter extends CustomPainter {
  Animation<Alignment> focalPointAnimation;
  Path cross;
  Paint foregroundPaint;

  FocalPointPainter(this.focalPointAnimation)
      : super(repaint: focalPointAnimation) {
    foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = Colors.white70;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (cross == null) {
      initCross(size);
    }

    Offset translation = focalPointAnimation.value.alongSize(size);
    canvas.translate(translation.dx, translation.dy);
    canvas.drawPath(cross, foregroundPaint);
  }

  @override
  bool hitTest(Offset position) => true;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void initCross(Size size) {
    var s = size.shortestSide / 8;
    cross = Path()
      ..moveTo(-s, 0)
      ..relativeLineTo(s * 0.75, 0)
      ..moveTo(s, 0)
      ..relativeLineTo(-s * 0.75, 0)
      ..moveTo(0, s)
      ..relativeLineTo(0, -s * 0.75)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: s * 0.85));
  }
}
