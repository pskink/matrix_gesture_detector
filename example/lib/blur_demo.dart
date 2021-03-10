import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_drawing/path_drawing.dart';

class BlurDemo extends StatefulWidget {
  @override
  _BlurDemoState createState() => _BlurDemoState();
}

class _BlurDemoState extends State<BlurDemo> {
  ValueNotifier<int> imageLoaded = ValueNotifier(0);
  ValueNotifier<Matrix4>? notifier;
  ImageData? sharp;
  ImageData? blur;

  @override
  void initState() {
    super.initState();
    imageLoaded.addListener(() => setState(() {}));
    sharp = ImageData('assets/sharp.jpg', imageLoaded);
    blur = ImageData('assets/blur.jpg', imageLoaded);
    notifier = ValueNotifier(Matrix4.identity());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sharp!.resolve(context);
    blur!.resolve(context);
  }

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) => notifier!.value = m,
      child: CustomPaint(
        painter: BlurPainter(notifier, sharp, blur),
      ),
    );
  }
}

class ImageData {
  String assetName;
  ImageStream? imageStream;
  ImageProvider imageProvider;
  ui.Image? image;
  ValueNotifier<int> notifier;
  late Size size;

  ImageData(this.assetName, this.notifier)
      : imageProvider = AssetImage(assetName);

  void resolve(BuildContext context) {
    ImageStream? oldImageStream = imageStream;
    imageStream = imageProvider.resolve(createLocalImageConfiguration(context));
    if (imageStream!.key != oldImageStream?.key) {
      oldImageStream?.removeListener(ImageStreamListener(imageLoaded));
      imageStream!.addListener(ImageStreamListener(imageLoaded));
    }
  }

  void imageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    print('image [$assetName] loaded: $imageInfo');
    image = imageInfo.image;
    size = Size(image!.width.toDouble(), image!.height.toDouble());
    notifier.value++;
  }
}

class BlurPainter extends CustomPainter {
  ValueNotifier<Matrix4>? notifier;
  ImageData? sharp;
  ImageData? blur;
  Path? path;
  Paint borderPaint = Paint();
  Paint imagePaint = Paint();
  Paint blurredPaint = Paint();
  late Rect outRect;

  BlurPainter(this.notifier, this.sharp, this.blur) : super(repaint: notifier);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (sharp!.image == null || blur!.image == null) return;

    if (path == null) {
      FittedSizes fs = applyBoxFit(BoxFit.contain, sharp!.size, size);
      outRect = Alignment.center.inscribe(fs.destination, Offset.zero & size);
      borderPaint
        ..color = Colors.green
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 4.0;

      path = parseSvgPathData(
          'M8,15 C8,15 0,10 0,5 0,0 7,1 8,4 c1,-3 8,-4 8,1 0,5 -6,6 -8,10 z');
      Rect bounds = path!.getBounds();
      Rect deflated = outRect.deflate(100);
      var scale = deflated.width / bounds.width;
      Matrix4 matrix = Matrix4.diagonal3Values(scale, scale, 1.0);
      path = path!.transform(matrix.storage).shift(deflated.topLeft);

      scale = outRect.width / sharp!.size.width;
      matrix = Matrix4.diagonal3Values(scale, scale, 1.0);
      matrix.leftTranslate(outRect.left, outRect.top);
      imagePaint.shader = createShader(sharp!.image!, matrix.storage);
      blurredPaint
        ..shader = createShader(blur!.image!, matrix.storage)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 32)
        ..colorFilter = ColorFilter.mode(Colors.black38, BlendMode.srcOver);
    }

    Path transformedPath = path!.transform(notifier!.value.storage);
    canvas
      ..clipRect(outRect.inflate(32))
      ..drawRect(outRect, blurredPaint)
      ..drawShadow(transformedPath, Colors.green, 24.0, false)
      ..drawPath(transformedPath, imagePaint)
      ..drawPath(transformedPath, borderPaint);
  }

  ui.Shader createShader(ui.Image image, Float64List matrix4) {
    return ImageShader(image, TileMode.clamp, TileMode.clamp, matrix4);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
