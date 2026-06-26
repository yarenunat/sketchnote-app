// Cursor TODO:
// This file should define the Drift database schema for notebook & page
// METADATA (titles, cover paths, page order, created/modified timestamps,
// brush presets, settings). Actual stroke geometry (potentially large) is
// likely better stored as compact binary blobs per-page (either as a Drift
// BLOB column or as separate files referenced by path) rather than as
// normalized SQL rows-per-point — that would be far too slow to write/read.
//
// Suggested tables:
//   Notebooks(id, title, coverAssetPath, createdAt, modifiedAt, sortIndex)
//   Pages(id, notebookId, pageIndex, backgroundType, strokeDataBlob /
//         strokeDataFilePath, thumbnailPath)
//   BrushPresets(id, name, settingsJson, isUserCreated)
//
// Steps:
// 1. `dart pub add drift sqlite3_flutter_libs path_provider path` (already
//    in pubspec.yaml — just run `flutter pub get`).
// 2. Define `@DriftDatabase(tables: [...])` with table classes using Drift's
//    `Table` + `Column` API.
// 3. Run build_runner (`dart run build_runner build`) to generate the
//    `.g.dart` part file.
// 4. Implement a `StorageService` (separate file) wrapping this database
//    with the higher-level methods the viewmodels actually call
//    (getAllNotebooks, saveStrokeBatch, etc.) — don't let viewmodels talk
//    to Drift directly.
//
// Leaving this as a stub/comment file rather than guessing at generated
// code, since Drift's codegen output depends on the exact package version
// resolved at `pub get` time.
