import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedWord extends StatelessWidget {
  final String word;
  final double x;
  final double y;

  const AnimatedWord({
    super.key,
    required this.word,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      left: x,
      top: y,
      child: Text(
        word,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 6,
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(0, 0),
            )
          ],
        ),
      ),
    );
  }
}
