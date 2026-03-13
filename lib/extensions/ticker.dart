import 'package:flutter/material.dart';

class AutoScrollTicker extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration initialDelay;
  final Duration pauseAtEnd;
  final int scrollSpeedFactor; 
  final ScrollPhysics physics;

  const AutoScrollTicker({
    super.key,
    required this.text,
    this.style,
    this.initialDelay = const Duration(milliseconds: 800),
    this.pauseAtEnd = const Duration(milliseconds: 600),
    this.scrollSpeedFactor = 12,
    this.physics = const BouncingScrollPhysics(),
  });

  @override
  State<AutoScrollTicker> createState() => _AutoScrollTickerState();
}

class _AutoScrollTickerState extends State<AutoScrollTicker> {
  final ScrollController _controller = ScrollController();
  bool _forward = true;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  @override
  void didUpdateWidget(AutoScrollTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart if text changes
    if (oldWidget.text != widget.text) {
      _running = false;
      _forward = true;
      _controller.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
    }
  }

  Future<void> _startScroll() async {
    if (_running) return;
    _running = true;
    await Future.delayed(widget.initialDelay);
    _animate();
  }

  Future<void> _animate() async {
    while (mounted && _running) {
      if (!_controller.hasClients) break;
      final maxScroll = _controller.position.maxScrollExtent;

      // Text fits — no scrolling needed
      if (maxScroll <= 0) {
        _running = false;
        return;
      }

      if (_forward) {
        await _controller.animateTo(
          maxScroll,
          duration: Duration(
            milliseconds: (maxScroll * widget.scrollSpeedFactor).toInt(),
          ),
          curve: Curves.linear,
        );
        await Future.delayed(widget.pauseAtEnd);
        _forward = false;
      } else {
        await _controller.animateTo(
          0,
          duration: Duration(
            milliseconds: (maxScroll * widget.scrollSpeedFactor).toInt(),
          ),
          curve: Curves.linear,
        );
        await Future.delayed(widget.pauseAtEnd);
        _forward = true;
      }
    }
  }

  @override
  void dispose() {
    _running = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: widget.physics,
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}