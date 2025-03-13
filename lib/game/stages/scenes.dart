import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/game.dart';

class TextButton extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final void Function() onPressed;

  const TextButton(this.text, {super.key, this.style, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border(
                  bottom: BorderSide(
                      color:
                          style == null ? Thematic.fg1 : style!.color ?? Thematic.fg1))),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(text, style: style ?? TextStyle(color: Thematic.fg1)),
        ));
  }
}

class ClickToContinue extends StatelessWidget {
  final String buttonText;
  final void Function() onPressed;
  final Widget subScene;

  const ClickToContinue(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      required this.subScene});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: subScene),
          Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(buttonText, onPressed: onPressed))
        ],
      ),
    );
  }
}

class Textual extends StatelessWidget {
  final List<InlineSpan> children;
  final TextStyle? style;
  final TextAlign? textAlign;

  const Textual({super.key, required this.children, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: C.black,
        child: Center(
            child: Text.rich(
          TextSpan(children: children),
          style: style != null
              ? (style!..copyWith(color: Thematic.fg1))
              : TextStyle(color: Thematic.fg1),
          textAlign: textAlign,
        )));
  }
}

class CinematicImagery extends StatelessWidget {
  final Widget top;
  final String bottom;
  final TextStyle? style;

  const CinematicImagery(
      {super.key, required this.top, required this.bottom, this.style});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: C.black,
        child: Padding(
          padding: const EdgeInsets.all(42),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            SizedBox(height: 160, width: 400, child: top),
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(
                  text: bottom,
                  style: style != null
                      ? (style!..copyWith(color: Thematic.fg1))
                      : TextStyle(color: Thematic.fg1, fontSize: 24)),
              textAlign: TextAlign.center,
            )
          ]),
        ));
  }
}

class CustomCinematicImagery extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final TextStyle? style;

  const CustomCinematicImagery(
      {super.key, required this.top, required this.bottom, this.style});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: C.black,
        child: Padding(
          padding: const EdgeInsets.all(42),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            SizedBox(height: 160, width: 400, child: top),
            const SizedBox(height: 22),
            bottom
          ]),
        ));
  }
}
