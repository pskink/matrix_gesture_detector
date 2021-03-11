import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class TransformDemo4 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TransformDemo4State();
}

class TransformDemo4State extends State<TransformDemo4>
    with TickerProviderStateMixin {
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  bool? shouldScale = true;
  bool? shouldRotate = true;
  late AnimationController controller;

  Alignment? focalPoint = Alignment.center;

  Animation<Alignment>? focalPointAnimation;
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
        children: makeControls() + makeMainWidget(getBody()),
      ),
    );
  }

  Body getBody() {
    String lbl = 'use your fingers to ';
    if (shouldRotate! && shouldScale!)
      return Body(lbl + 'rotate / scale', Icons.crop_rotate, Color(0x6600aa00));
    if (shouldRotate!)
      return Body(lbl + 'rotate', Icons.crop_rotate, Color(0x6600aa00));
    if (shouldScale!)
      return Body(lbl + 'scale', Icons.transform, Color(0x660000aa));
    return Body('you have to select at least one checkbox above', Icons.warning,
        Color(0x66aa0000));
  }

  Animation<Alignment> makeFocalPointAnimation(Alignment? begin, Alignment? end) {
    return controller.drive(AlignmentTween(begin: begin, end: end));
  }

  List<Widget> makeControls() => [
        ListTile(
          title: Text('focal point'),
          trailing: DropdownButton(
            onChanged: (dynamic value) {
              setState(() {
                focalPointAnimation =
                    makeFocalPointAnimation(focalPointAnimation!.value, value);
                focalPoint = value;
                controller.forward(from: 0.0);
              });
            },
            value: focalPoint,
            items: items as List<DropdownMenuItem<dynamic>>?,
          ),
        ),
        CheckboxListTile(
          value: shouldScale,
          onChanged: (bool? value) {
            setState(() {
              shouldScale = value;
            });
          },
          title: Text('scale'),
        ),
        CheckboxListTile(
          value: shouldRotate,
          onChanged: (bool? value) {
            setState(() {
              shouldRotate = value;
            });
          },
          title: Text('rotate'),
        ),
      ];

  List<Widget> makeMainWidget(Body body) => [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: MatrixGestureDetector(
              onMatrixUpdate: (m, tm, sm, rm) {
                notifier.value = m;
              },
              shouldTranslate: false,
              shouldScale: shouldScale!,
              shouldRotate: shouldRotate!,
              focalPointAlignment: focalPoint!,
              clipChild: false,
              child: CustomPaint(
                foregroundPainter: FocalPointPainter(focalPointAnimation),
                child: AnimatedBuilder(
                  animation: notifier,
                  builder: (ctx, child) => makeTransform(ctx, child, body),
                ),
              ),
            ),
          ),
        )
      ];

  Widget makeTransform(BuildContext context, Widget? child, Body body) {
    return Transform(
      transform: notifier.value,
      child: GridPaper(
        color: Color(0xaa0000ff),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 4.0, color: Color(0xaa00cc00)),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                  alignment: focalPoint!,
                ),
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            child: Stack(
              key: ValueKey('$shouldRotate-$shouldScale'),
              fit: StackFit.expand,
              children: <Widget>[
                FittedBox(
                  child: Icon(
                    body.icon,
                    color: body.color,
                  ),
                ),
                Container(
                  alignment: Alignment(0, -0.5),
                  child: Text(
                    body.label,
                    style: Theme.of(context).textTheme.display2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Body {
  String label;
  IconData icon;
  Color color;

  Body(this.label, this.icon, this.color);
}

class FocalPointPainter extends CustomPainter {
  Animation<Alignment>? focalPointAnimation;
  Path? cross;
  late Paint foregroundPaint;

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

    Offset translation = focalPointAnimation!.value.alongSize(size);
    canvas.translate(translation.dx, translation.dy);
    canvas.drawPath(cross!, foregroundPaint);
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
