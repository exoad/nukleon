import 'package:flutter/material.dart';
import 'package:project_yellow_cake/engine/engine.dart';

class UIToggleButton1 extends StatefulWidget {
  final bool toggled;
  final void Function(bool) onSwitch;
  final SpriteSet<ButtonSpriteStates>? spriteSet;

  const UIToggleButton1(
      {super.key, this.toggled = false, this.spriteSet, required this.onSwitch});

  @override
  State<UIToggleButton1> createState() => _UIToggleButton1State();
}

class _UIToggleButton1State extends State<UIToggleButton1> {
  late bool _active;
  late SpriteSet<ButtonSpriteStates> spriteSet;

  @override
  void initState() {
    super.initState();
    _active = widget.toggled;
    spriteSet = widget.spriteSet ??
        SpriteSetMapper<ButtonSpriteStates>(<ButtonSpriteStates, SpriteSetProperty>{
          ButtonSpriteStates.normal: (
            sprite: const SpriteTextureKey("ui_content",
                spriteName: "Reactor_Button_1_Normal"),
            transform: Matrix4.identity()
          ),
          ButtonSpriteStates.pressed: (
            sprite: const SpriteTextureKey("ui_content",
                spriteName: "Reactor_Button_1_Pressed"),
            transform: Matrix4.translation(Vector3(0, 1, 0))
          ),
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() => _active = !_active);
          widget.onSwitch(_active);
        },
        child: SpriteWidget(<AtlasSprite>[
          spriteSet.resolveTextureKey(<ButtonSpriteStates>{
            _active ? ButtonSpriteStates.pressed : ButtonSpriteStates.normal
          }).findTexture()
        ], transformations: <Matrix4>[
          Matrix4.identity()
        ]));
  }
}
