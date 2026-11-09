import 'package:flutter/material.dart';

/// Draws a basketball tank-top jersey in the team's colours with the player's
/// number and surname, so products need no image files.
class JerseyArt extends StatelessWidget {
  const JerseyArt({
    super.key,
    required this.primary,
    required this.secondary,
    required this.number,
    required this.label,
  });

  final Color primary;
  final Color secondary;
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: CustomPaint(
        painter: _JerseyPainter(primary, secondary, number, label),
      ),
    );
  }
}

class _JerseyPainter extends CustomPainter {
  _JerseyPainter(this.primary, this.secondary, this.number, this.label);

  final Color primary;
  final Color secondary;
  final String number;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(w * 0.30, h * 0.04) // left strap top
      ..lineTo(w * 0.40, h * 0.04)
      ..quadraticBezierTo(w * 0.50, h * 0.24, w * 0.60, h * 0.04) // neckline
      ..lineTo(w * 0.70, h * 0.04) // right strap top
      ..quadraticBezierTo(w * 0.72, h * 0.26, w * 0.88, h * 0.32) // right armhole
      ..lineTo(w * 0.86, h * 0.96)
      ..quadraticBezierTo(w * 0.50, h * 1.00, w * 0.14, h * 0.96) // hem
      ..lineTo(w * 0.12, h * 0.32)
      ..quadraticBezierTo(w * 0.28, h * 0.26, w * 0.30, h * 0.04) // left armhole
      ..close();

    // Soft shadow
    canvas.drawShadow(body, Colors.black, 6, false);

    // Body fill
    canvas.drawPath(body, Paint()..color = primary);

    // Trim along neck + armholes
    final trim = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.40, h * 0.04)
        ..quadraticBezierTo(w * 0.50, h * 0.24, w * 0.60, h * 0.04),
      trim,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.70, h * 0.04)
        ..quadraticBezierTo(w * 0.72, h * 0.26, w * 0.88, h * 0.32),
      trim,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.30, h * 0.04)
        ..quadraticBezierTo(w * 0.28, h * 0.26, w * 0.12, h * 0.32),
      trim,
    );

    // Side panels
    final panel = Paint()..color = secondary.withValues(alpha: 0.85);
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.42, w * 0.035, h * 0.52), panel);
    canvas.drawRect(Rect.fromLTWH(w * 0.845, h * 0.42, w * 0.035, h * 0.52), panel);

    // Outline so white jerseys stay visible on light backgrounds
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final outline = _contrastOutline(primary, secondary);

    // Surname across the chest
    _drawText(
      canvas,
      label.toUpperCase(),
      center: Offset(w * 0.5, h * 0.36),
      maxWidth: w * 0.62,
      fontSize: w * 0.085,
      fill: secondary,
      outline: outline,
      letterSpacing: 1.2,
    );

    // Big number
    _drawText(
      canvas,
      number,
      center: Offset(w * 0.5, h * 0.62),
      maxWidth: w * 0.62,
      fontSize: w * 0.34,
      fill: secondary,
      outline: outline,
    );
  }

  Color _contrastOutline(Color base, Color text) {
    // Outline the lettering with whichever of black/white contrasts the body.
    return base.computeLuminance() > 0.6
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.35);
  }

  void _drawText(
    Canvas canvas,
    String text, {
    required Offset center,
    required double maxWidth,
    required double fontSize,
    required Color fill,
    required Color outline,
    double letterSpacing = 0,
  }) {
    TextPainter build(Paint? foreground, Color? color) => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: letterSpacing,
              height: 1,
              foreground: foreground,
              color: color,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

    final stroke = build(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = fontSize * 0.08
        ..color = outline,
      null,
    );
    final solid = build(null, fill);

    final scale = solid.width > maxWidth ? maxWidth / solid.width : 1.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    final offset = Offset(-solid.width / 2, -solid.height / 2);
    stroke.paint(canvas, offset);
    solid.paint(canvas, offset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_JerseyPainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.number != number ||
      old.label != label;
}
