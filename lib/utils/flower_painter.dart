
import 'package:flutter/material.dart';

class FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Цвета для цветочных элементов
    const purpleColor = Color(0xFF8A74B9);
    const tealColor = Color(0xFF4AA0A0);

    // Рисуем листья и цветы
    paintLeaf(canvas, Offset(0, size.height * 0.15), size.width * 0.35,
        size.height * 0.08, tealColor);
    paintLeaf(
        canvas,
        Offset(size.width - size.width * 0.35, size.height * 0.12),
        size.width * 0.35,
        size.height * 0.09,
        purpleColor);
    paintLeaf(canvas, Offset(-size.width * 0.15, size.height * 0.25),
        size.width * 0.4, size.height * 0.11, purpleColor);
    paintLeaf(
        canvas,
        Offset(size.width - size.width * 0.25, size.height * 0.28),
        size.width * 0.4,
        size.height * 0.1,
        tealColor);
    paintLeaf(canvas, Offset(-size.width * 0.05, size.height * 0.38),
        size.width * 0.35, size.height * 0.09, tealColor);
    paintLeaf(canvas, Offset(size.width - size.width * 0.3, size.height * 0.42),
        size.width * 0.35, size.height * 0.1, purpleColor);

    // Добавляем точки (звезды) на фоне
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.08), 1.5, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 2, paint);
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.18), 1.5, paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.35), 2, paint);
  }

  void paintLeaf(Canvas canvas, Offset position, double width, double height,
      Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(position.dx + width * 0.5, position.dy);
    path.quadraticBezierTo(
        position.dx + width * 0.25,
        position.dy + height * 0.5,
        position.dx + width * 0.5,
        position.dy + height);
    path.quadraticBezierTo(position.dx + width * 0.75,
        position.dy + height * 0.5, position.dx + width * 0.5, position.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
