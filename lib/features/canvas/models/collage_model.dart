import 'dart:io';
import 'package:flutter/material.dart';

/// Represents a photo/image element placed on the canvas.
class CollageItem {
  final String id;
  final File imageFile;
  final Offset position;   // Center of the item
  final double scale;      // 1.0 = natural size
  final double rotation;   // In radians
  final Size size;         // Original natural size of the image

  const CollageItem({
    required this.id,
    required this.imageFile,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.size,
  });

  CollageItem copyWith({
    String? id,
    File? imageFile,
    Offset? position,
    double? scale,
    double? rotation,
    Size? size,
  }) {
    return CollageItem(
      id: id ?? this.id,
      imageFile: imageFile ?? this.imageFile,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
    );
  }

  /// The bounding box of this item at its current transform.
  Rect get bounds {
    final halfW = (size.width * scale) / 2;
    final halfH = (size.height * scale) / 2;
    return Rect.fromCenter(
      center: position,
      width: halfW * 2,
      height: halfH * 2,
    );
  }
}
