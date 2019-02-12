import 'package:flutter/material.dart';

import 'custom_painter_demo.dart';
import 'transform_demo.dart';

void main() => runApp(MaterialApp(
      title: 'MatrixGestureDetector Demo',
      routes: {
        'customPainterDemo': (ctx) => CustomPainterDemo(),
        'transformDemo': (ctx) => TransformDemo(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text('MatrixGestureDetector Demo'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () => showDemo(context, 'customPainterDemo'),
                      leading: Icon(Icons.image),
                      title: Text(
                        'CustomPainter Demo',
                      ),
                      subtitle: Text(
                          'this demo shows how to use a matrix for a custom canvas drawing'),
                    ),
                    ListTile(
                      onTap: () => showDemo(context, 'transformDemo'),
                      leading: Icon(Icons.image),
                      title: Text(
                        'Transform Demo',
                      ),
                      subtitle: Text(
                          'this demo shows how to use a matrix with a standard Transform widget'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ));

showDemo(BuildContext context, String routeName) {
  print('showing $routeName...');
  Navigator.of(context).pushNamed(routeName);
}
