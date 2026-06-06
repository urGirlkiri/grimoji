import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/utils/math.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class RecipeTutorial extends StatelessWidget {
  const RecipeTutorial({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Text(
            "Match ${recipe.requiredAmount} to craft",
            textAlign: TextAlign.center,
            style: GoogleFonts.eagleLake(
              color: palette.moonlight,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: degToRad(-15),
                child: Column(
                  children: List.generate(
                    recipe.requiredAmount,
                    (index) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: palette.twilight.withValues(alpha: .8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: palette.magicCyan.withValues(alpha: .5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.magicCyan.withValues(
                                    alpha: .2,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: EmojiWidget.svg(
                              path: recipe.ingredient.svg,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.double_arrow_rounded,
                color: palette.magicCyan,
                size: 32,
              ),
              const SizedBox(width: 16),
              EmojiWidget.lottie(
                path: recipe.yields.lottie,
                useDropShadow: true,
                size: 80,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
