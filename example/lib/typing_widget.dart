// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class DelayTween extends Tween<double> {
//   DelayTween({double begin, double end, this.delay}) : super(begin: begin, end: end);

//   final double delay;

//   @override
//   double lerp(double t) => super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

//   @override
//   double evaluate(Animation<double> animation) => lerp(animation.value);
// }

// class TypingWidget extends StatefulWidget {
//   // const TypingWidget({
//   //   this.color,
//   //   this.size = 50.0,
//   //   this.itemBuilder,
//   //   this.duration = const Duration(milliseconds: 1400),
//   //   this.controller,
//   // })  : assert(!(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
//   //           'You should specify either a itemBuilder or a color'),
//   //       assert(size != null)

//   const TypingWidget(this.color);
//   final Color color;
//   // final double size;
//   // final IndexedWidgetBuilder itemBuilder;
//   // final Duration duration;
//   // final AnimationController controller;

//   @override
//   _TypingWidgetState createState() => _TypingWidgetState();
// }

// class _TypingWidgetState extends State<TypingWidget> with SingleTickerProviderStateMixin {
//   AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox.fromSize(
//         size: Size(100, 50),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: List.generate(3, (i) {
//             return ScaleTransition(
//               scale: DelayTween(begin: 0.0, end: 1.0, delay: i * .2).animate(_controller),
//               child: SizedBox.fromSize(
//                 size: Size.square(25),
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
