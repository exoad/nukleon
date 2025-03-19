import 'package:dotted_border/dotted_border.dart';
import 'package:nukleon/src/engine/debug/debug.dart';
import 'package:nukleon/src/engine/engine.dart';

extension DebugifyBorderWidget on Widget {
  Widget get debuggableStatic =>
      kShowDebugBorders ? _DebugBorderWidget(child: this) : this;
}

extension FlashingDebugifyBorderWidget on Widget {
  Widget get debuggableFlashing =>
      kShowDebugBorders ? _FlashingDebugWidget(child: this) : this;
}

class _DebugBorderWidget extends StatelessWidget {
  final Widget child;

  const _DebugBorderWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
        padding: EdgeInsets.zero,
        strokeWidth: 2,
        dashPattern: const <double>[4, 2],
        color: ColorHelper.randomColor(),
        child: child);
  }
}

class _FlashingDebugWidget extends StatefulWidget {
  final Widget child;

  const _FlashingDebugWidget({required this.child});

  @override
  State<_FlashingDebugWidget> createState() => _FlashingDebugWidgetState();
}

class _FlashingDebugWidgetState extends State<_FlashingDebugWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 255, 0, 220),
      end: const Color.fromRGBO(0, 0, 0, 0),
    ).chain(CurveTween(curve: Curves.linear)).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Container(
          color: _colorAnimation.value,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
