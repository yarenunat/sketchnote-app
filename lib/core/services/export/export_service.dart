import '../../../features/notebook/models/notebook_models.dart';

/// Exports notebooks/pages to shareable formats.
///
/// Cursor TODO:
/// - PDF export: use the `pdf` package, render each page's strokes as
///   vector paths into the PDF canvas (NOT a rasterized image) so exported
///   notes stay crisp and print well — this is a key "professional" bar to
///   clear vs. competitors that just screenshot the canvas.
/// - PNG export: render a `ui.PictureRecorder` at a high pixel ratio (e.g.
///   3x) for sharing individual pages as images.
/// - Native `.sknproj`-style bundle export: zip (via the `archive` package)
///   the notebook's pages + a manifest JSON, for backup/transfer between
///   devices, distinct from PDF/PNG which are for sharing OUT of the app.
class ExportService {
  Future<String> exportNotebookAsPdf(Notebook notebook) {
    throw UnimplementedError('Cursor: implement vector PDF export.');
  }

  Future<String> exportPageAsImage(NotebookPage page, {double pixelRatio = 3.0}) {
    throw UnimplementedError('Cursor: implement PNG export.');
  }
}
