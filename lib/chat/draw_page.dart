import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Draw extends StatefulWidget {
  final Uint8List imageData;
  final Widget loadingWidget;

  Draw({this.imageData, this.loadingWidget});
  @override
  _DrawState createState() => _DrawState();

  // @override
  // String get name => 'draw_page';
}

class _DrawState extends State<Draw> {
  Color selectedColor = Colors.red;
  Color pickerColor = Colors.black;
  double strokeWidth = 10.0;
  List<List<DrawingPoints>> points = List();
  StrokeCap strokeCap = StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
  ];

  ui.Image image;
  bool isImageloaded = false;
  bool isDrawing = false;

  void initState() {
    super.initState();
    init();
  }

  Future<Null> init() async {
    image = await loadImage(widget.imageData);
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<ByteData> saveToImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawingPainter painter = DrawingPainter(pointsList: points, image: image);

    // try {
    //   if (!Navigator.of(context, rootNavigator: true).canPop()) {
    //     bottomHeight = BottomNavigation.of(context).context.size.height;
    //     // RenderBox box = keyContext.findRenderObject() as RenderBox;
    //     // bottomHeight = box.size.height;
    //   }
    // } catch (e) {
    //   print(e);
    // }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double imageWidth = image.width.toDouble();
    double imageHeight = image.height.toDouble();
    double ratio = screenWidth / imageWidth;

    double cropWidth = screenWidth;
    double cropHeight = imageHeight * ratio;

    painter.paint(canvas, Size(screenWidth, screenHeight));
    final picture = recorder.endRecording();
    final img = await picture.toImage(screenWidth.toInt(), screenHeight.toInt());
    Rect rect =
        Rect.fromCenter(center: Offset(screenWidth / 2, screenHeight / 2), width: cropWidth, height: cropHeight);
    final croppedImage = await getCroppedImage(img, rect, Rect.fromLTWH(0, 0, cropWidth, cropHeight));
    final pngBytes = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes;
  }

  Future<ui.Image> getCroppedImage(ui.Image image, Rect src, Rect dst) async {
    var pictureRecorder = new ui.PictureRecorder();
    Canvas canvas = new Canvas(pictureRecorder);
    canvas.drawImageRect(image, src, dst, Paint());
    return pictureRecorder.endRecording().toImage(dst.width.floor(), dst.height.floor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !isImageloaded
            ? widget.loadingWidget ??
                Container(
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
            : Stack(
                // fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    color: Colors.black,
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      RenderBox renderBox = context.findRenderObject();
                      var loc = renderBox.globalToLocal(details.globalPosition);
                      if (distance(points.last.last.points, loc) > 50) return;

                      setState(() {
                        points.last.add(DrawingPoints(
                            points: details.globalPosition,
                            paint: Paint()
                              ..strokeCap = strokeCap
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanStart: (details) {
                      setState(() {
                        isDrawing = true;
                        RenderBox renderBox = context.findRenderObject();
                        List<DrawingPoints> newPoints = new List<DrawingPoints>();
                        newPoints.add(DrawingPoints(
                            points: renderBox.globalToLocal(details.globalPosition),
                            paint: Paint()
                              ..strokeCap = strokeCap
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                        points.add(newPoints);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        isDrawing = false;
                        points.last.add(null);
                      });
                    },
                    child: CustomPaint(
                      size: Size.square(MediaQuery.of(context).size.height),
                      painter: DrawingPainter(pointsList: points, image: image),
                    ),
                  ),
                  isDrawing
                      ? Container()
                      : Positioned(
                          bottom: 0,
                          left: 16,
                          right: 16,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                  color: Colors.white54),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          // trackHeight: trackHeight,
                                          activeTrackColor: selectedColor,
                                          // trackShape: RoundRangeSliderThumbShape(),
                                          thumbColor: selectedColor,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: strokeWidth / 2, disabledThumbRadius: 10),
                                          // overlayShape: RoundSliderOverlayShape(
                                          //     overlayRadius: 0.0),
                                        ),
                                        child: Slider(
                                            // activeColor: selectedColor,
                                            value: strokeWidth,
                                            max: 40.0,
                                            min: 2.0,
                                            onChanged: (val) {
                                              setState(() {
                                                strokeWidth = val;
                                              });
                                            })),
                                    SafeArea(
                                      bottom: true,
                                      top: false,
                                      child: Container(
                                        height: 50,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: colors.map((c) => colorCircle(c)).toList()),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                  Positioned(
                    right: 10,
                    top: 100,
                    child: Visibility(
                      visible: !isDrawing && points.length > 0 && points.last.length > 0,
                      child: RawMaterialButton(
                        constraints: BoxConstraints(maxWidth: 60, maxHeight: 60),
                        onPressed: () {
                          setState(() {
                            points.clear();
                          });
                        },
                        child: new Icon(
                          Icons.clear,
                          color: Colors.grey,
                          // size: 20.0,
                        ),
                        shape: new CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.white,
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 160,
                    child: Visibility(
                      visible: !isDrawing && points.length > 0 && points.last.length > 0,
                      child: RawMaterialButton(
                        constraints: BoxConstraints(maxWidth: 60, maxHeight: 60),
                        // enableFeedback: false,
                        onPressed: () {
                          setState(() {
                            if (points.length == 1)
                              points[0].clear();
                            else
                              points.removeLast();
                          });
                        },
                        child: new Icon(
                          Icons.undo,
                          color: Colors.grey,
                          // size: 20.0,
                        ),
                        shape: new CircleBorder(),
                        elevation: 2.0,
                        // splashColor: Colors.blue,
                        fillColor: Colors.white,
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    // top: 30,
                    child: SafeArea(
                      child: RawMaterialButton(
                        constraints: BoxConstraints(maxWidth: 60, maxHeight: 60),
                        onPressed: () async {
                          var result = await saveToImage();
                          Navigator.of(context).pop(Uint8List.view(result.buffer));
                        },
                        child: new Icon(
                          Icons.send,
                          color: Colors.grey,
                          // size: 20.0,
                        ),
                        shape: new CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.white,
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    // top: 10,
                    child: SafeArea(
                      child: RawMaterialButton(
                        constraints: BoxConstraints(maxWidth: 60, maxHeight: 60),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: new Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                          // size: 20.0,
                        ),
                        shape: new CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.white,
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                  )
                ],
              ));
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    // Widget colorPicker = GestureDetector(
    //   onTap: () {
    //     showDialog(
    //       context: context,
    //       child: AlertDialog(
    //         title: const Text('Pick a color!'),
    //         content: SingleChildScrollView(
    //           child: ColorPicker(
    //             pickerColor: pickerColor,
    //             onColorChanged: (color) {
    //               pickerColor = color;
    //             },
    //             enableLabel: true,
    //             pickerAreaHeightPercent: 0.8,
    //           ),
    //         ),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: const Text('Save'),
    //             onPressed: () {
    //               setState(() => selectedColor = pickerColor);
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    //   child: ClipOval(
    //     child: Container(
    //       padding: const EdgeInsets.only(bottom: 16.0),
    //       height: 36,
    //       width: 36,
    //       decoration: BoxDecoration(
    //           gradient: LinearGradient(
    //         colors: [Colors.red, Colors.green, Colors.blue],
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomRight,
    //       )),
    //     ),
    //   ),
    // );
    // listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    Color outLineColor;
    if (selectedColor == color) {
      outLineColor = color == Colors.white ? Colors.black54 : Colors.white70;
    } else {
      outLineColor = Colors.transparent;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: outLineColor, width: 4),
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: ClipOval(
          child: Container(
            // padding: const EdgeInsets.only(bottom: 16.0),
            height: 40,
            width: 40,
            color: color,
          ),
        ),
      ),
    );
  }

  double distance(Offset pos1, Offset pos2) {
    var dis = sqrt(pow(pos2.dx - pos1.dx, 2) + pow(pos2.dy - pos1.dy, 2));
    return dis;
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList, this.image});
  List<List<DrawingPoints>> pointsList;
  List<Offset> offsetPoints = List();
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(canvas: canvas, image: image, rect: Rect.fromLTWH(0, 0, size.width, size.height));
    for (int j = 0; j < pointsList.length; j++) {
      for (int i = 0; i < pointsList[j].length - 1; i++) {
        if (pointsList[j][i] != null && pointsList[j][i + 1] != null) {
          canvas.drawLine(pointsList[j][i].points, pointsList[j][i + 1].points, pointsList[j][i].paint);
        } else if (pointsList[j][i] != null && pointsList[j][i + 1] == null) {
          offsetPoints.clear();
          offsetPoints.add(pointsList[j][i].points);
          offsetPoints.add(Offset(pointsList[j][i].points.dx + 0.1, pointsList[j][i].points.dy + 0.1));
          canvas.drawPoints(ui.PointMode.points, offsetPoints, pointsList[j][i].paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
