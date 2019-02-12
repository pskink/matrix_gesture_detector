import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class TransformDemo extends StatelessWidget {
  final Matrix4 matrix = Matrix4.identity();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Transform Demo'),
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return MatrixGestureDetector(
            onMatrixUpdate: (Matrix4 m) {
              setState(() {
                m.copyInto(matrix);
              });
            },
            child: Transform(
              transform: matrix,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white30,
                  ),
                  Positioned.fill(
                    child: Container(
                      transform: matrix,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.deepPurple.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: FlutterLogoDecoration(),
                    padding: EdgeInsets.all(32),
                    alignment: Alignment(0, -0.5),
                    child: Text(
                      'use your two fingers to translate / rotate / scale ...',
                      style: Theme.of(context).textTheme.display2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
