# Cursor Prompt — SketchNote Implementation

Paste everything below this line into Cursor as your starting instruction.

---

You are implementing **SketchNote**, a professional, stylus-first sketching
and note-taking app for tablets, built in Flutter (single codebase for iOS
and Android). The project skeleton already exists in this repo: folder
structure, data models, and stub files with full doc-comments describing
exactly what each piece should do. **Read `README.md` first** for the
architecture overview, then read every file under `lib/` before writing
code — most files already contain a `Cursor TODO` doc comment with a
step-by-step implementation plan. Follow those plans; don't invent a
different architecture.

## Product context

This is a premium drawing/note-taking app in the spirit of Procreate +
GoodNotes, aimed at people who draw or write by hand on a tablet for hours
at a time. The bar is "feels as good as native iPad apps," not "a basic
canvas demo." Reference screenshots (already informed the existing models
and doc comments) show:
1. A library "shelf" of notebook covers with title + page count.
2. An open notebook with a fanned, page-turning navigation feel.
3. A deep "Brush Studio" editor with categorized parameters (stroke path,
   stabilization, taper, shape, grain, rendering, wet mix, color dynamics,
   dynamics, pencil settings) and a live preview pad.
4. A "Brush Library" picker: left category rail + named presets with live
   stroke-shape thumbnails.

## Hard requirements — do not compromise on these

1. **Input fidelity.** Must support Apple Pencil and Samsung S Pen (and
   generic styluses) with pressure and tilt, AND plain finger touch, on
   the same canvas. Use raw `Listener`/`PointerEvent` handling (already
   stubbed in `engine/input/stylus_input_handler.dart`) — do not use
   `GestureDetector` for the drawing path, since its gesture arena adds
   latency and can drop/delay pressure data.
2. **Palm rejection.** A user must be able to rest their drawing hand on
   the screen while inking with the stylus without stray marks. Implement
   per the heuristics already documented in `stylus_input_handler.dart`,
   and make it a togglable setting.
3. **Performance.** Target 60fps minimum (ideally matching the display's
   max refresh rate, e.g. 120Hz on ProMotion/high-refresh Android tablets)
   while actively drawing, even on pages with thousands of prior strokes.
   This requires the "bake committed strokes into a cached layer, only
   redraw the active stroke" approach described in `canvas_painter.dart`
   and `canvas_view.dart` — do not re-render the entire stroke history
   every frame.
4. **Natural brush feel.** Strokes must respond convincingly to pressure
   (width + opacity) and, where available, tilt — not just a fixed-width
   line. Implement the smoothing + width-profile pipeline described in
   `stroke_builder.dart`. A technical/inking pen, a pencil, and a soft
   charcoal-like brush (see `brush_settings.dart` presets) should feel
   visibly different from each other.
5. **Stroke editability / resolution independence.** Persist raw input
   points (not only a baked vector Path) so strokes remain crisp at any
   zoom level and could be re-processed later if brush algorithms improve.
6. **Vector PDF export.** Export must redraw stroke paths into the PDF
   canvas (via the `pdf` package), not rasterize a screenshot — this
   matters for users who print or archive notes.

## Build order (please follow this sequence)

1. **Drawing engine core** — this is the product. Implement, in order:
   - `engine/input/stylus_input_handler.dart` (palm rejection + InputPoint
     stream)
   - `engine/stroke/stroke_builder.dart` (smoothing — implement a
     Catmull-Rom or Perfect-Freehand-style variable-width algorithm —
     pressure-driven width/opacity, taper, stabilization)
   - `engine/brushes/brush_settings.dart` consumers: get the 3 default
     presets (`technicalPen`, `pencil`, `softCharcoal`) actually rendering
     distinctly different strokes
   - `canvas/views/canvas_painter.dart` + `canvas_view.dart` with the
     baked-layer caching strategy
   - `canvas/viewmodels/canvas_viewmodel.dart` (undo/redo, active brush
     state)
   - Get a single page drawing smoothly with all 3 brushes, pressure, palm
     rejection, and undo/redo working before moving on. This is the
     make-or-break milestone — validate it on a real tablet + real stylus
     before proceeding.
2. **Persistence** — implement the Drift schema (`storage/app_database.dart`
   has the planned tables) and `storage_service.dart`, wire the canvas
   viewmodel to autosave.
3. **Notebook & library UI** — `library/views/library_screen.dart`,
   `notebook/views/notebook_pager_screen.dart`, their viewmodels. Get
   create/open/delete/duplicate notebook working end-to-end with real
   persisted data.
4. **Toolbar UI** — `toolbar/views/toolbar_view.dart` and
   `toolbar/widgets/brush_library_sheet.dart`. Wire to the canvas
   viewmodel's brush/color/undo state.
5. **Export** — `core/services/export/export_service.dart`: vector PDF
   first, then PNG.
6. **Brush Studio editor** (`toolbar/views/brush_studio_screen.dart`) —
   explicitly deprioritized; only build this after 1–5 are solid and
   feel good in hand. It's a power-user feature, not core to launch.
7. **Settings screen** (palm rejection toggle, finger-drawing toggle,
   handedness/toolbar side, units) — `features/settings/` is currently
   empty, create it following the same models/views/viewmodels pattern as
   other features.

## Conventions to follow throughout

- State management is Riverpod (`flutter_riverpod`), using `Notifier` +
  `NotifierProvider` as already set up in the existing viewmodel stubs.
  Keep all business logic out of widgets.
- Keep the engine layer (`features/canvas/engine/**`) free of Flutter
  widget/BuildContext dependencies where possible, so stroke math is
  independently testable.
- Add unit tests under `test/unit/` for the stroke smoothing/width-profile
  math specifically — this is the part most worth covering, since visual
  regressions here are easy to miss by eye and hard to debug once UI is
  built on top.
- Every new non-trivial file should follow the existing pattern: a doc
  comment at the top explaining what the file/class is for and any
  non-obvious design decisions, the way the existing stub files do.
- Don't add new third-party packages beyond what's in `pubspec.yaml`
  without a clear reason — if you do, explain why in a comment at the
  point of use.

## What "done" looks like for v1

A user can: open the app to a library of notebooks, create a new one,
open it to a blank page, draw smoothly and naturally with a stylus
(pressure-sensitive, palm-rejected) or a finger, switch between a small
set of distinct good-feeling brushes and colors, undo/redo, add/delete
pages, navigate between pages, and export a notebook as a vector PDF —
all while maintaining 60fps+ during active drawing, with autosaved
persistence so nothing is lost on app close/reopen.

Start by reading `README.md` and every `Cursor TODO` comment in
`lib/features/canvas/engine/`, then propose your implementation plan for
milestone 1 before writing code.
