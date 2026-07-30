import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 가로 스크롤 리스트 — 마우스가 위에 있을 때 세로 휠(트랙패드 포함)로도 좌우로 넘길 수 있게
/// PointerScrollEvent를 가로 스크롤 오프셋으로 변환해준다(넷플릭스 웹 카탈로그와 동일한 동작).
class HScrollList extends StatefulWidget {
  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double gap;

  const HScrollList({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.gap = 12,
  });

  @override
  State<HScrollList> createState() => _HScrollListState();
}

class _HScrollListState extends State<HScrollList> {
  final _controller = ScrollController();

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final delta = event.scrollDelta.dy.abs() > event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    final target = (_controller.offset + delta).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.jumpTo(target);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          itemCount: widget.itemCount,
          separatorBuilder: (context, index) => SizedBox(width: widget.gap),
          itemBuilder: widget.itemBuilder,
        ),
      ),
    );
  }
}
