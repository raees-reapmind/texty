import 'package:flutter/material.dart';

class SlidableWrapper extends StatefulWidget {
  final Widget child;
  final Widget background;
  final double actionWidth;

  const SlidableWrapper({
    required this.child,
    required this.background,
    this.actionWidth = 80.0,
    super.key,
  });

  @override
  State<SlidableWrapper> createState() => _SlidableWrapperState();
}

class _SlidableWrapperState extends State<SlidableWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragExtent = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) return;
    setState(() {
      _dragExtent += details.primaryDelta!;
      if (_dragExtent > 0) _dragExtent = 0;
      if (_dragExtent < -widget.actionWidth * 1.5) {
        _dragExtent = -widget.actionWidth * 1.5;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent < -widget.actionWidth / 2) {
      _animateTo(-widget.actionWidth);
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _dragExtent, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Background - revealed when swiped
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: widget.actionWidth,
              child: widget.background,
            ),
          ),
        ),
        // Foreground - slides to reveal background
        Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.white, // Ensure foreground is opaque to taps
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
