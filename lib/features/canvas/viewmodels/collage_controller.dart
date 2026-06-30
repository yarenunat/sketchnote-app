import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/collage_model.dart';

/// Manages the list of [CollageItem]s placed on a canvas page.
class CollageController extends StateNotifier<List<CollageItem>> {
  CollageController() : super([]);

  final ImagePicker _picker = ImagePicker();
  String? _selectedItemId;

  String? get selectedItemId => _selectedItemId;

  // ── Image picking ────────────────────────────────────────────────────────

  Future<void> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null) return;
    await _addImageFile(File(xFile.path));
  }

  Future<void> pickFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (xFile == null) return;
    await _addImageFile(File(xFile.path));
  }

  Future<void> _addImageFile(File file) async {
    // Decode to get natural size
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final naturalSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Scale down very large images to fit reasonably on canvas
    const maxDim = 400.0;
    double initialScale = 1.0;
    if (naturalSize.width > maxDim || naturalSize.height > maxDim) {
      initialScale = maxDim / (naturalSize.width > naturalSize.height
          ? naturalSize.width
          : naturalSize.height);
    }

    final item = CollageItem(
      id: const Uuid().v4(),
      imageFile: file,
      position: const Offset(200, 300), // Default drop position
      scale: initialScale,
      rotation: 0.0,
      size: naturalSize,
    );

    state = [...state, item];
    _selectedItemId = item.id;
  }

  // ── Transform ────────────────────────────────────────────────────────────

  void updateTransform({
    required String itemId,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    state = state.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(
        position: position,
        scale: scale?.clamp(0.1, 10.0),
        rotation: rotation,
      );
    }).toList();
  }

  // ── Selection ────────────────────────────────────────────────────────────

  void selectItem(String? id) {
    _selectedItemId = id;
    // Notify by doing a no-op state update so listeners rebuild
    state = [...state];
  }

  void deselectAll() => selectItem(null);

  // ── Z-order ──────────────────────────────────────────────────────────────

  void bringToFront(String itemId) {
    final idx = state.indexWhere((i) => i.id == itemId);
    if (idx < 0 || idx == state.length - 1) return;
    final item = state[idx];
    final newList = [...state]..removeAt(idx)..add(item);
    state = newList;
  }

  void sendToBack(String itemId) {
    final idx = state.indexWhere((i) => i.id == itemId);
    if (idx <= 0) return;
    final item = state[idx];
    final newList = [...state]..removeAt(idx)..insert(0, item);
    state = newList;
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  void deleteItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
    if (_selectedItemId == itemId) _selectedItemId = null;
  }

  void deleteSelected() {
    if (_selectedItemId != null) deleteItem(_selectedItemId!);
  }
}

final collageControllerProvider =
    StateNotifierProvider.family<CollageController, List<CollageItem>, String>(
  (ref, pageId) => CollageController(),
);
