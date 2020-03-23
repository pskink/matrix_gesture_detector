# matrix_gesture_detector

`MatrixGestureDetector` detects translation, scale and rotation gestures
and combines them into `Matrix4` object that can be used by `Transform` widget
or by low level `CustomPainter` code. You can customize types of reported
gestures by passing `shouldTranslate`, `shouldScale` and `shouldRotate`
parameters.

## Getting Started

The usage is as follows:

```dart
  MatrixGestureDetector(
    onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
      setState(() {
        matrix = m;
      });
    },
    child: SomeWidgetThatUsesMatrix(
      matrix: matrix,
      ...
    )
  )
```
here: `SomeWidgetThatUsesMatrix` could be a `Transform` widget
([transform_demo.dart](https://github.com/pskink/matrix_gesture_detector/blob/master/example/lib/transform_demo.dart)) or a `CustomPaint` widget which
`CustomPainter` uses `Matrix4` in its low level drawing code
([custom_painter_demo.dart](https://github.com/pskink/matrix_gesture_detector/blob/master/example/lib/custom_painter_demo.dart)).

## Examples

![bounded demo gif](https://i.imgur.com/TEHJVYC.gif) ![grid rotation demo gif](https://i.imgur.com/H3BbzuB.gif) ![blur demo gif](https://i.imgur.com/8JAwcEV.gif)
