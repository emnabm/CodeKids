import 'dart:ui';

import 'package:flutter/material.dart';

/// Paints smooth curved dashed lines connecting zigzag map nodes.
class ZigzagPathPainter extends CustomPainter {
  const ZigzagPathPainter({
    required this.nodeCenters,
    required this.activeStates,
  });

  final List<Offset> nodeCenters;
  final List<bool> activeStates;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCenters.length < 2) return;

    for (var i = 0; i < nodeCenters.length - 1; i++) {
      final start = nodeCenters[i];
      final end = nodeCenters[i + 1];
      final isUnlockedSegment =
          i < activeStates.length && activeStates[i] && activeStates[i + 1];

      final midY = (start.dy + end.dy) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          midY,
          end.dx,
          midY,
          end.dx,
          end.dy,
        );

      final paint = Paint()
        ..color = isUnlockedSegment
            ? const Color(0xFF8B6EFF).withValues(alpha: 0.78)
            : const Color(0xFF534C80).withValues(alpha: 0.65)
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _drawDashedPath(canvas, path, paint, dashLength: 8, gapLength: 8);
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ZigzagPathPainter oldDelegate) {
    if (oldDelegate.nodeCenters.length != nodeCenters.length) return true;
    for (var i = 0; i < nodeCenters.length; i++) {
      if (oldDelegate.nodeCenters[i] != nodeCenters[i]) return true;
    }
    return false;
  }
}
