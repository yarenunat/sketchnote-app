# SketchNote

Professional, stylus-first sketching & note-taking app for tablets.
Targets Apple Pencil, Samsung S Pen (and equivalents), and finger input,
on a single Flutter codebase (iOS + Android).

## Architecture overview

```
lib/
  core/                     App-wide stuff, not feature-specific
    theme/                  Design tokens (colors, text styles)
    constants/              Tunable constants (canvas, performance, input)
    services/
      storage/              Local persistence (Drift db + service interface)
      export/                PDF / image / bundle export
      sync/                  (placeholder, post-v1)

  features/
    canvas/                 The drawing surface itself — the core of the app
      engine/
        input/              Raw pointer -> InputPoint, palm rejection
        brushes/             BrushSettings model + built-in presets
        stroke/              Smoothing + stroke building pipeline
      models/                Transient canvas-side models
      views/                 CanvasView (Listener+CustomPaint), CanvasPainter
      viewmodels/            Riverpod state for the active page
      widgets/

    notebook/                A notebook = ordered pages
      models/                Notebook / NotebookPage / StrokeData (persisted)
      views/                 NotebookPagerScreen (page-turn navigation)
      viewmodels/
      widgets/

    toolbar/                 Drawing tool UI
      views/                 ToolbarView, BrushStudioScreen (deep brush editor)
      widgets/                BrushLibrarySheet (preset picker)

    library/                  Home screen: shelf/grid of notebooks
      models/
      views/                  LibraryScreen
      viewmodels/
      widgets/

    settings/                 App preferences (palm rejection, handedness, ...)

  shared/                     Cross-feature reusable widgets/extensions
```

## Key design decisions already made

- **State management:** Riverpod (`flutter_riverpod`), via `Notifier`/
  `NotifierProvider`. Keep viewmodels free of widget/BuildContext concerns.
- **Drawing input:** raw `Listener` + `PointerEvent`, NOT `GestureDetector`,
  to get full pressure/tilt/pointer-kind data at native sampling rate and to
  implement custom palm rejection. See
  `features/canvas/engine/input/stylus_input_handler.dart` for the detailed
  plan.
- **Stroke rendering:** committed strokes are baked into a cached
  Picture/Image layer; only the in-progress stroke is redrawn every frame.
  This is essential for 60fps+ with long drawing sessions.
- **Persistence:** Drift for notebook/page metadata; stroke geometry as
  compact binary blobs (NOT normalized per-point SQL rows). Raw input
  points (not just baked paths) should be retained so strokes stay
  editable/resolution-independent.
- **Export:** PDF export must be vector-based (re-draw paths into the PDF
  canvas), not a rasterized screenshot, for crisp printing.

## What's intentionally NOT built yet

Every file with a `Cursor TODO` block is a stub: signatures, doc comments,
and the implementation plan are in place, but the body throws
`UnimplementedError` or returns a `Placeholder()` widget. This is by design
so Cursor can implement against a clear, consistent architecture rather
than inventing its own structure per-file.

See `docs/cursor_prompt.md` for the prompt to hand to Cursor next.
