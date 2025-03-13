import 'package:nukleon/engine/engine.dart';

class DebugButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final void Function() onPressed;

  const DebugButton(
      {super.key,
      required this.text,
      this.color = C.magenta,
      this.textColor = C.black,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            backgroundColor: WidgetStatePropertyAll<Color>(color),
            shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: textColor, width: 1.5)))),
        child: Text(text, style: TextStyle(color: textColor)));
  }
}
