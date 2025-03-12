import 'package:nukleon/engine/engine.dart';

class NullPainter extends CustomPainter {
  const NullPainter();

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = G.fasterPainter;
    canvas.drawRect(Rect.fromPoints(Offset.zero, Offset(size.width / 2, size.height / 2)),
        p..color = C.magenta);
    canvas.drawRect(
        Rect.fromPoints(
            Offset(size.width / 2, size.height / 2), Offset(size.width, size.height)),
        p);
    canvas.drawRect(
        Rect.fromPoints(Offset(0, size.height / 2), Offset(size.width / 2, size.height)),
        p..color = C.black);
    canvas.drawRect(
        Rect.fromPoints(Offset(size.width / 2, 0), Offset(size.width, size.height / 2)),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
