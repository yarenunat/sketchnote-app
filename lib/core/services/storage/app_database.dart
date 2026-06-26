import 'package:drift/drift.dart';
import 'database_connection.dart' as connection;

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
  AppDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 1;
}
