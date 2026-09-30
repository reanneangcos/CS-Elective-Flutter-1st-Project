import 'package:flutter/material.dart';

import '../theme/emerald_theme.dart';

class Pokeball extends StatelessWidget {
  const Pokeball({super.key, this.size = 40, this.muted = false});
  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PokeballPainter(muted)),
    ),
  );
}

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter(this.muted);
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final paint = Paint()..isAntiAlias = false;
    final circle = Rect.fromCircle(center: center, radius: radius);
    canvas.save();
    canvas.clipPath(Path()..addOval(circle));
    canvas.drawCircle(center, radius, paint..color = EmeraldTheme.paper);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height / 2),
      paint..color = muted ? EmeraldTheme.line : EmeraldTheme.red,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - 1.5, size.width, 3),
      paint..color = EmeraldTheme.dark,
    );
    canvas.restore();
    canvas.drawCircle(
      center,
      radius,
      paint
        ..color = EmeraldTheme.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      center,
      size.width * .17,
      paint
        ..style = PaintingStyle.fill
        ..color = EmeraldTheme.dark,
    );
    canvas.drawCircle(
      center,
      size.width * .09,
      paint..color = EmeraldTheme.paper,
    );
  }

  @override
  bool shouldRepaint(_PokeballPainter oldDelegate) =>
      muted != oldDelegate.muted;
}
