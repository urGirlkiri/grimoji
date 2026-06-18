import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/utils/context_data.dart';

class VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;

  const VolumeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onChanged != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Text(
            label,
            style: GoogleFonts.eagleLake(
              color: isEnabled
                  ? context.palette.midnight
                  : context.palette.slate,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: context.palette.mist,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.palette.slate, width: 2),
            boxShadow: [
              BoxShadow(
                color: context.palette.voidBlack.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isEnabled
                  ? context.palette.midnight
                  : context.palette.slate,
              inactiveTrackColor: context.palette.twilight.withValues(
                alpha: 0.3,
              ),
              thumbColor: isEnabled
                  ? context.palette.trueWhite
                  : context.palette.mist,
              overlayColor: isEnabled
                  ? context.palette.midnight.withValues(alpha: 0.2)
                  : Colors.transparent,
              trackHeight: 8.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
