import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('NotebookEntity')
class Notebooks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get coverAssetPath => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get modifiedAt => dateTime()();
  IntColumn get sortIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PageEntity')
class Pages extends Table {
  TextColumn get id => text()();
  TextColumn get notebookId => text().references(Notebooks, #id)();
  IntColumn get pageIndex => integer()();
  TextColumn get backgroundType => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StrokeEntity')
class Strokes extends Table {
  TextColumn get id => text()();
  TextColumn get pageId => text().references(Pages, #id)();
  TextColumn get brushSettingsJson => text()();
  IntColumn get colorValue => integer()();
  TextColumn get boundingBoxJson => text()();
  BlobColumn get geometryBlob => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Notebooks, Pages, Strokes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sketchnote_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

