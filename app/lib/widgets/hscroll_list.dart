import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// PC에서 마우스 왼쪽 버튼을 누른 채로 드래그해도 가로 스크롤이 되도록 허용한다.
/// 기본 ScrollBehavior는 마우스 드래그를 스크롤이 아닌 텍스트 선택 등으로 취급해 무시하기 때문에
/// dragDevices에 마우스를 추가해줘야 한다.
class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// 가로 스크롤 리스트 — 마우스가 위에 있을 때 세로 휠(트랙패드 포함)로도 좌우로 넘길 수 있고,
/// PC에서는 마우스로 직접 드래그해서도 넘길 수 있다(넷플릭스 웹 카탈로그와 동일한 동작).
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
        child: ScrollConfiguration(
          behavior: _DragScrollBehavior(),
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: widget.padding,
            itemCount: widget.itemCount,
            separatorBuilder: (context, index) => SizedBox(width: widget.gap),
            itemBuilder: widget.itemBuilder,
          ),
        ),
      ),
    );
  }
}
