import 'package:flutter/material.dart';

import 'custom_painter_demo.dart';
import 'transform_demo.dart';
import 'transform_demo2.dart';

List<Demo> demos = [
  Demo(
      'CustomPainter Demo',
      'this demo shows how to use a matrix for a custom canvas drawing',
      CustomPainterDemo()),
  Demo(
      'Transform Demo',
      'this demo shows how to use a matrix with a standard Transform widget',
      TransformDemo()),
  Demo(
      'Transform Demo 2',
      'this demo shows how to use a matrix with a standard Transform widget',
      TransformDemo2()),
];

void main() => runApp(MaterialApp(
      title: 'MatrixGestureDetector Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('MatrixGestureDetector Demo'),
        ),
        body: Builder(
          builder: (BuildContext ctx) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: demos
                      .map((demo) => ListTile(
                            onTap: () => showDemo(ctx, demo),
                            leading: Icon(Icons.image),
                            title: Text(demo.title),
                            subtitle: Text(demo.subtitle),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    ));

showDemo(BuildContext ctx, Demo demo) {
  print('showing ${demo.title}...');
  Navigator.of(ctx).push(MaterialPageRoute(builder: (ctx) => demo.widget));
}

class Demo {
  String title;
  String subtitle;
  Widget widget;

  Demo(this.title, this.subtitle, this.widget);
}
