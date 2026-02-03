import 'dart:math';
import 'package:flutter/material.dart';

Map<String, Offset> applyRepulsion(
    Map<String, Offset> positions, double minDistance) {
  const double force = 0.4;
  final result = Map<String, Offset>.from(positions);
  final entries = result.entries.toList();

  for (int i = 0; i < entries.length; i++) {
    for (int j = i + 1; j < entries.length; j++) {
      final a = entries[i];
      final b = entries[j];

      final dx = b.value.dx - a.value.dx;
      final dy = b.value.dy - a.value.dy;
      final distSq = dx * dx + dy * dy;

      if (distSq < minDistance * minDistance && distSq > 0.01) {
        final dist = sqrt(distSq);
        final repulsion = (minDistance - dist) * force;

        final offsetX = repulsion * dx / dist;
        final offsetY = repulsion * dy / dist;

        result[a.key] = result[a.key]! - Offset(offsetX, offsetY);
        result[b.key] = result[b.key]! + Offset(offsetX, offsetY);
      }
    }
  }

  return result;
}
