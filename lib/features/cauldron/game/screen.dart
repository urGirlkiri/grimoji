import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/level/hint_screen/loading.dart';
import 'package:grimoji/features/level/widgets/footer/powerup.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/responsive_screen.dart';

class CauldronPlayScreen extends StatefulWidget {
  const CauldronPlayScreen({super.key});

  @override
  State<CauldronPlayScreen> createState() => _CauldronPlayScreenState();
}

class _CauldronPlayScreenState extends State<CauldronPlayScreen> {
  late final CauldronGame _game;
  bool _isGameInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isGameInitialized) {
      _game = CauldronGame(
        colorScheme: context.theme.colorScheme,
        globalScale: context.globalScale,
        context: context,
      );
      _isGameInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/emo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ResponsiveScreen(
        topMessageArea: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: palette.twilight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              AppIcon(
                fileName: _game.paused ? 'resume' : 'pause',
                enableAnimation: false,
                onTap: () {
                  setState(() {
                    _game.paused ? _game.resumeEngine() : _game.pauseEngine();
                  });
                },
              ),
              const Spacer(),
              Container(
                width: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    palette.dusk.withValues(alpha: 0.15),
                    palette.twilight,
                  ),
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(
                    color: palette.slate.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/goth_emo.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      palette.voidBlack.withValues(alpha: 0.05),
                      BlendMode.dstATop,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.voidBlack,
                      offset: Offset(0, 6 * scale),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text("0", style: context.theme.textTheme.bodyLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmojiWidget.svg(emoji: Emojis.moai, size: 20),
                        const SizedBox(width: 3),
                        Text('20000', style: context.theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                decoration: ShapeDecoration(
                  color: palette.dusk.withValues(alpha: .8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      width: 2,
                      color: palette.magicCyan.withValues(alpha: .5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text("Next", style: context.theme.textTheme.titleSmall),
                    const SizedBox(width: 6),
                    EmojiWidget.svg(emoji: Emojis.heart, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
        squarishMainArea: Column(
          children: [
            Expanded(
              child: GameWidget(
                game: _game,
                loadingBuilder: (context) => const Center(child: Loading()),
              ),
            ),
          ],
        ),
        rectangularMenuArea: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: palette.twilight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: FittedBox(
            child: Row(
              children: [
                PowerupBtn(
                  bgColor: palette.dusk,
                  assetPath: Emojis.shakingFace.svg,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                PowerupBtn(
                  bgColor: palette.dusk,
                  assetPath: Emojis.boomerang.svg,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                PowerupBtn(
                  bgColor: palette.dusk,
                  assetPath: Emojis.testTube.svg,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                PowerupBtn(
                  bgColor: palette.dusk,
                  assetPath: Emojis.flyingSaucer.svg,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _game.dispose();
  }
}
