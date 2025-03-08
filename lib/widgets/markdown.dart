import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final bool selectable;
  final bool textAlignCenter;

  const MarkdownTextWidget({
    super.key,
    required this.text,
    required this.textAlignCenter,
    this.textStyle,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        textAlign: textAlignCenter ? WrapAlignment.center : WrapAlignment.start,
        p: textStyle ??
            const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
        h1: textStyle?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ) ??
            const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
        h2: textStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
            const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
        strong: const TextStyle(fontWeight: FontWeight.bold),
        em: const TextStyle(fontStyle: FontStyle.italic),
      ),
      selectable: selectable,
    );
  }
}
