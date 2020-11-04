import 'package:flutter/material.dart';
import 'dart:math' as math;

class DelayTween extends Tween<double> {
  DelayTween({double begin, double end, this.delay})
      : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class TypingAnimation extends StatefulWidget {
  const TypingAnimation(this.color);
  final Color color;

  @override
  _TypingAnimationState createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double size = 25.0;
  int length = 3;
  int pow = 5;

  Color color;
  @override
  void initState() {
    super.initState();

    color = widget.color ?? Colors.blue;

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(size * 2, size),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(length, (i) {
          return ScaleTransition(
            scale: DelayTween(begin: 0.5, end: 0.8, delay: i * .15)
                .animate(_controller),
            child: SizedBox.fromSize(
              size: Size.square(size / 2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withOpacity((i + pow - length) / pow),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
