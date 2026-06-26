// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, NotebookEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverAssetPathMeta =
      const VerificationMeta('coverAssetPath');
  @override
  late final GeneratedColumn<String> coverAssetPath = GeneratedColumn<String>(
      'cover_asset_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modifiedAtMeta =
      const VerificationMeta('modifiedAt');
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
      'modified_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sortIndexMeta =
      const VerificationMeta('sortIndex');
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
      'sort_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, coverAssetPath, createdAt, modifiedAt, sortIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(Insertable<NotebookEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_asset_path')) {
      context.handle(
          _coverAssetPathMeta,
          coverAssetPath.isAcceptableOrUnknown(
              data['cover_asset_path']!, _coverAssetPathMeta));
    } else if (isInserting) {
      context.missing(_coverAssetPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
          _modifiedAtMeta,
          modifiedAt.isAcceptableOrUnknown(
              data['modified_at']!, _modifiedAtMeta));
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(_sortIndexMeta,
          sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta));
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotebookEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotebookEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      coverAssetPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cover_asset_path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      modifiedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_at'])!,
      sortIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_index'])!,
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }
}

class NotebookEntity extends DataClass implements Insertable<NotebookEntity> {
  final String id;
  final String title;
  final String coverAssetPath;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final int sortIndex;
  const NotebookEntity(
      {required this.id,
      required this.title,
      required this.coverAssetPath,
      required this.createdAt,
      required this.modifiedAt,
      required this.sortIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['cover_asset_path'] = Variable<String>(coverAssetPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      title: Value(title),
      coverAssetPath: Value(coverAssetPath),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      sortIndex: Value(sortIndex),
    );
  }

  factory NotebookEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotebookEntity(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      coverAssetPath: serializer.fromJson<String>(json['coverAssetPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'coverAssetPath': serializer.toJson<String>(coverAssetPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  NotebookEntity copyWith(
          {String? id,
          String? title,
          String? coverAssetPath,
          DateTime? createdAt,
          DateTime? modifiedAt,
          int? sortIndex}) =>
      NotebookEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        coverAssetPath: coverAssetPath ?? this.coverAssetPath,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        sortIndex: sortIndex ?? this.sortIndex,
      );
  NotebookEntity copyWithCompanion(NotebooksCompanion data) {
    return NotebookEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverAssetPath: data.coverAssetPath.present
          ? data.coverAssetPath.value
          : this.coverAssetPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotebookEntity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverAssetPath: $coverAssetPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, coverAssetPath, createdAt, modifiedAt, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotebookEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverAssetPath == this.coverAssetPath &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.sortIndex == this.sortIndex);
}

class NotebooksCompanion extends UpdateCompanion<NotebookEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> coverAssetPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverAssetPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebooksCompanion.insert({
    required String id,
    required String title,
    required String coverAssetPath,
    required DateTime createdAt,
    required DateTime modifiedAt,
    required int sortIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        coverAssetPath = Value(coverAssetPath),
        createdAt = Value(createdAt),
        modifiedAt = Value(modifiedAt),
        sortIndex = Value(sortIndex);
  static Insertable<NotebookEntity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? coverAssetPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverAssetPath != null) 'cover_asset_path': coverAssetPath,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? coverAssetPath,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<int>? sortIndex,
      Value<int>? rowid}) {
    return NotebooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      coverAssetPath: coverAssetPath ?? this.coverAssetPath,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverAssetPath.present) {
      map['cover_asset_path'] = Variable<String>(coverAssetPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverAssetPath: $coverAssetPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, PageEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notebookIdMeta =
      const VerificationMeta('notebookId');
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
      'notebook_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES notebooks (id)'));
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _backgroundTypeMeta =
      const VerificationMeta('backgroundType');
  @override
  late final GeneratedColumn<String> backgroundType = GeneratedColumn<String>(
      'background_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, notebookId, pageIndex, backgroundType, thumbnailPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages';
  @override
  VerificationContext validateIntegrity(Insertable<PageEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
          _notebookIdMeta,
          notebookId.isAcceptableOrUnknown(
              data['notebook_id']!, _notebookIdMeta));
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('background_type')) {
      context.handle(
          _backgroundTypeMeta,
          backgroundType.isAcceptableOrUnknown(
              data['background_type']!, _backgroundTypeMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PageEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      notebookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notebook_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      backgroundType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}background_type']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }
}

class PageEntity extends DataClass implements Insertable<PageEntity> {
  final String id;
  final String notebookId;
  final int pageIndex;
  final String? backgroundType;
  final String? thumbnailPath;
  const PageEntity(
      {required this.id,
      required this.notebookId,
      required this.pageIndex,
      this.backgroundType,
      this.thumbnailPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['notebook_id'] = Variable<String>(notebookId);
    map['page_index'] = Variable<int>(pageIndex);
    if (!nullToAbsent || backgroundType != null) {
      map['background_type'] = Variable<String>(backgroundType);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      id: Value(id),
      notebookId: Value(notebookId),
      pageIndex: Value(pageIndex),
      backgroundType: backgroundType == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundType),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
    );
  }

  factory PageEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageEntity(
      id: serializer.fromJson<String>(json['id']),
      notebookId: serializer.fromJson<String>(json['notebookId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      backgroundType: serializer.fromJson<String?>(json['backgroundType']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'notebookId': serializer.toJson<String>(notebookId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'backgroundType': serializer.toJson<String?>(backgroundType),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
    };
  }

  PageEntity copyWith(
          {String? id,
          String? notebookId,
          int? pageIndex,
          Value<String?> backgroundType = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent()}) =>
      PageEntity(
        id: id ?? this.id,
        notebookId: notebookId ?? this.notebookId,
        pageIndex: pageIndex ?? this.pageIndex,
        backgroundType:
            backgroundType.present ? backgroundType.value : this.backgroundType,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
      );
  PageEntity copyWithCompanion(PagesCompanion data) {
    return PageEntity(
      id: data.id.present ? data.id.value : this.id,
      notebookId:
          data.notebookId.present ? data.notebookId.value : this.notebookId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      backgroundType: data.backgroundType.present
          ? data.backgroundType.value
          : this.backgroundType,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageEntity(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('backgroundType: $backgroundType, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, notebookId, pageIndex, backgroundType, thumbnailPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageEntity &&
          other.id == this.id &&
          other.notebookId == this.notebookId &&
          other.pageIndex == this.pageIndex &&
          other.backgroundType == this.backgroundType &&
          other.thumbnailPath == this.thumbnailPath);
}

class PagesCompanion extends UpdateCompanion<PageEntity> {
  final Value<String> id;
  final Value<String> notebookId;
  final Value<int> pageIndex;
  final Value<String?> backgroundType;
  final Value<String?> thumbnailPath;
  final Value<int> rowid;
  const PagesCompanion({
    this.id = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.backgroundType = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagesCompanion.insert({
    required String id,
    required String notebookId,
    required int pageIndex,
    this.backgroundType = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        notebookId = Value(notebookId),
        pageIndex = Value(pageIndex);
  static Insertable<PageEntity> custom({
    Expression<String>? id,
    Expression<String>? notebookId,
    Expression<int>? pageIndex,
    Expression<String>? backgroundType,
    Expression<String>? thumbnailPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notebookId != null) 'notebook_id': notebookId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (backgroundType != null) 'background_type': backgroundType,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? notebookId,
      Value<int>? pageIndex,
      Value<String?>? backgroundType,
      Value<String?>? thumbnailPath,
      Value<int>? rowid}) {
    return PagesCompanion(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      pageIndex: pageIndex ?? this.pageIndex,
      backgroundType: backgroundType ?? this.backgroundType,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (backgroundType.present) {
      map['background_type'] = Variable<String>(backgroundType.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('backgroundType: $backgroundType, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrokesTable extends Strokes
    with TableInfo<$StrokesTable, StrokeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrokesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
      'page_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES pages (id)'));
  static const VerificationMeta _brushSettingsJsonMeta =
      const VerificationMeta('brushSettingsJson');
  @override
  late final GeneratedColumn<String> brushSettingsJson =
      GeneratedColumn<String>('brush_settings_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxJsonMeta =
      const VerificationMeta('boundingBoxJson');
  @override
  late final GeneratedColumn<String> boundingBoxJson = GeneratedColumn<String>(
      'bounding_box_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _geometryBlobMeta =
      const VerificationMeta('geometryBlob');
  @override
  late final GeneratedColumn<Uint8List> geometryBlob =
      GeneratedColumn<Uint8List>('geometry_blob', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        pageId,
        brushSettingsJson,
        colorValue,
        boundingBoxJson,
        geometryBlob
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strokes';
  @override
  VerificationContext validateIntegrity(Insertable<StrokeEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('brush_settings_json')) {
      context.handle(
          _brushSettingsJsonMeta,
          brushSettingsJson.isAcceptableOrUnknown(
              data['brush_settings_json']!, _brushSettingsJsonMeta));
    } else if (isInserting) {
      context.missing(_brushSettingsJsonMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('bounding_box_json')) {
      context.handle(
          _boundingBoxJsonMeta,
          boundingBoxJson.isAcceptableOrUnknown(
              data['bounding_box_json']!, _boundingBoxJsonMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxJsonMeta);
    }
    if (data.containsKey('geometry_blob')) {
      context.handle(
          _geometryBlobMeta,
          geometryBlob.isAcceptableOrUnknown(
              data['geometry_blob']!, _geometryBlobMeta));
    } else if (isInserting) {
      context.missing(_geometryBlobMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrokeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrokeEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_id'])!,
      brushSettingsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}brush_settings_json'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      boundingBoxJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bounding_box_json'])!,
      geometryBlob: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}geometry_blob'])!,
    );
  }

  @override
  $StrokesTable createAlias(String alias) {
    return $StrokesTable(attachedDatabase, alias);
  }
}

class StrokeEntity extends DataClass implements Insertable<StrokeEntity> {
  final String id;
  final String pageId;
  final String brushSettingsJson;
  final int colorValue;
  final String boundingBoxJson;
  final Uint8List geometryBlob;
  const StrokeEntity(
      {required this.id,
      required this.pageId,
      required this.brushSettingsJson,
      required this.colorValue,
      required this.boundingBoxJson,
      required this.geometryBlob});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['page_id'] = Variable<String>(pageId);
    map['brush_settings_json'] = Variable<String>(brushSettingsJson);
    map['color_value'] = Variable<int>(colorValue);
    map['bounding_box_json'] = Variable<String>(boundingBoxJson);
    map['geometry_blob'] = Variable<Uint8List>(geometryBlob);
    return map;
  }

  StrokesCompanion toCompanion(bool nullToAbsent) {
    return StrokesCompanion(
      id: Value(id),
      pageId: Value(pageId),
      brushSettingsJson: Value(brushSettingsJson),
      colorValue: Value(colorValue),
      boundingBoxJson: Value(boundingBoxJson),
      geometryBlob: Value(geometryBlob),
    );
  }

  factory StrokeEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrokeEntity(
      id: serializer.fromJson<String>(json['id']),
      pageId: serializer.fromJson<String>(json['pageId']),
      brushSettingsJson: serializer.fromJson<String>(json['brushSettingsJson']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      boundingBoxJson: serializer.fromJson<String>(json['boundingBoxJson']),
      geometryBlob: serializer.fromJson<Uint8List>(json['geometryBlob']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pageId': serializer.toJson<String>(pageId),
      'brushSettingsJson': serializer.toJson<String>(brushSettingsJson),
      'colorValue': serializer.toJson<int>(colorValue),
      'boundingBoxJson': serializer.toJson<String>(boundingBoxJson),
      'geometryBlob': serializer.toJson<Uint8List>(geometryBlob),
    };
  }

  StrokeEntity copyWith(
          {String? id,
          String? pageId,
          String? brushSettingsJson,
          int? colorValue,
          String? boundingBoxJson,
          Uint8List? geometryBlob}) =>
      StrokeEntity(
        id: id ?? this.id,
        pageId: pageId ?? this.pageId,
        brushSettingsJson: brushSettingsJson ?? this.brushSettingsJson,
        colorValue: colorValue ?? this.colorValue,
        boundingBoxJson: boundingBoxJson ?? this.boundingBoxJson,
        geometryBlob: geometryBlob ?? this.geometryBlob,
      );
  StrokeEntity copyWithCompanion(StrokesCompanion data) {
    return StrokeEntity(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      brushSettingsJson: data.brushSettingsJson.present
          ? data.brushSettingsJson.value
          : this.brushSettingsJson,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      boundingBoxJson: data.boundingBoxJson.present
          ? data.boundingBoxJson.value
          : this.boundingBoxJson,
      geometryBlob: data.geometryBlob.present
          ? data.geometryBlob.value
          : this.geometryBlob,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrokeEntity(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('brushSettingsJson: $brushSettingsJson, ')
          ..write('colorValue: $colorValue, ')
          ..write('boundingBoxJson: $boundingBoxJson, ')
          ..write('geometryBlob: $geometryBlob')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pageId, brushSettingsJson, colorValue,
      boundingBoxJson, $driftBlobEquality.hash(geometryBlob));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrokeEntity &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.brushSettingsJson == this.brushSettingsJson &&
          other.colorValue == this.colorValue &&
          other.boundingBoxJson == this.boundingBoxJson &&
          $driftBlobEquality.equals(other.geometryBlob, this.geometryBlob));
}

class StrokesCompanion extends UpdateCompanion<StrokeEntity> {
  final Value<String> id;
  final Value<String> pageId;
  final Value<String> brushSettingsJson;
  final Value<int> colorValue;
  final Value<String> boundingBoxJson;
  final Value<Uint8List> geometryBlob;
  final Value<int> rowid;
  const StrokesCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.brushSettingsJson = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.boundingBoxJson = const Value.absent(),
    this.geometryBlob = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrokesCompanion.insert({
    required String id,
    required String pageId,
    required String brushSettingsJson,
    required int colorValue,
    required String boundingBoxJson,
    required Uint8List geometryBlob,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pageId = Value(pageId),
        brushSettingsJson = Value(brushSettingsJson),
        colorValue = Value(colorValue),
        boundingBoxJson = Value(boundingBoxJson),
        geometryBlob = Value(geometryBlob);
  static Insertable<StrokeEntity> custom({
    Expression<String>? id,
    Expression<String>? pageId,
    Expression<String>? brushSettingsJson,
    Expression<int>? colorValue,
    Expression<String>? boundingBoxJson,
    Expression<Uint8List>? geometryBlob,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (brushSettingsJson != null) 'brush_settings_json': brushSettingsJson,
      if (colorValue != null) 'color_value': colorValue,
      if (boundingBoxJson != null) 'bounding_box_json': boundingBoxJson,
      if (geometryBlob != null) 'geometry_blob': geometryBlob,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrokesCompanion copyWith(
      {Value<String>? id,
      Value<String>? pageId,
      Value<String>? brushSettingsJson,
      Value<int>? colorValue,
      Value<String>? boundingBoxJson,
      Value<Uint8List>? geometryBlob,
      Value<int>? rowid}) {
    return StrokesCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      brushSettingsJson: brushSettingsJson ?? this.brushSettingsJson,
      colorValue: colorValue ?? this.colorValue,
      boundingBoxJson: boundingBoxJson ?? this.boundingBoxJson,
      geometryBlob: geometryBlob ?? this.geometryBlob,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (brushSettingsJson.present) {
      map['brush_settings_json'] = Variable<String>(brushSettingsJson.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (boundingBoxJson.present) {
      map['bounding_box_json'] = Variable<String>(boundingBoxJson.value);
    }
    if (geometryBlob.present) {
      map['geometry_blob'] = Variable<Uint8List>(geometryBlob.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrokesCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('brushSettingsJson: $brushSettingsJson, ')
          ..write('colorValue: $colorValue, ')
          ..write('boundingBoxJson: $boundingBoxJson, ')
          ..write('geometryBlob: $geometryBlob, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $StrokesTable strokes = $StrokesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [notebooks, pages, strokes];
}

typedef $$NotebooksTableCreateCompanionBuilder = NotebooksCompanion Function({
  required String id,
  required String title,
  required String coverAssetPath,
  required DateTime createdAt,
  required DateTime modifiedAt,
  required int sortIndex,
  Value<int> rowid,
});
typedef $$NotebooksTableUpdateCompanionBuilder = NotebooksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> coverAssetPath,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> sortIndex,
  Value<int> rowid,
});

final class $$NotebooksTableReferences
    extends BaseReferences<_$AppDatabase, $NotebooksTable, NotebookEntity> {
  $$NotebooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PagesTable, List<PageEntity>> _pagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pages,
          aliasName: 'notebooks__id__pages__notebook_id');

  $$PagesTableProcessedTableManager get pagesRefs {
    final manager = $$PagesTableTableManager($_db, $_db.pages)
        .filter((f) => f.notebookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$NotebooksTableFilterComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverAssetPath => $composableBuilder(
      column: $table.coverAssetPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortIndex => $composableBuilder(
      column: $table.sortIndex, builder: (column) => ColumnFilters(column));

  Expression<bool> pagesRefs(
      Expression<bool> Function($$PagesTableFilterComposer f) f) {
    final $$PagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.notebookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableFilterComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverAssetPath => $composableBuilder(
      column: $table.coverAssetPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortIndex => $composableBuilder(
      column: $table.sortIndex, builder: (column) => ColumnOrderings(column));
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverAssetPath => $composableBuilder(
      column: $table.coverAssetPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  Expression<T> pagesRefs<T extends Object>(
      Expression<T> Function($$PagesTableAnnotationComposer a) f) {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.notebookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableAnnotationComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$NotebooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotebooksTable,
    NotebookEntity,
    $$NotebooksTableFilterComposer,
    $$NotebooksTableOrderingComposer,
    $$NotebooksTableAnnotationComposer,
    $$NotebooksTableCreateCompanionBuilder,
    $$NotebooksTableUpdateCompanionBuilder,
    (NotebookEntity, $$NotebooksTableReferences),
    NotebookEntity,
    PrefetchHooks Function({bool pagesRefs})> {
  $$NotebooksTableTableManager(_$AppDatabase db, $NotebooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> coverAssetPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> sortIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotebooksCompanion(
            id: id,
            title: title,
            coverAssetPath: coverAssetPath,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            sortIndex: sortIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String coverAssetPath,
            required DateTime createdAt,
            required DateTime modifiedAt,
            required int sortIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotebooksCompanion.insert(
            id: id,
            title: title,
            coverAssetPath: coverAssetPath,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            sortIndex: sortIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NotebooksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({pagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (pagesRefs) db.pages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pagesRefs)
                    await $_getPrefetchedData<NotebookEntity, $NotebooksTable,
                            PageEntity>(
                        currentTable: table,
                        referencedTable:
                            $$NotebooksTableReferences._pagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$NotebooksTableReferences(db, table, p0).pagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.notebookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$NotebooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotebooksTable,
    NotebookEntity,
    $$NotebooksTableFilterComposer,
    $$NotebooksTableOrderingComposer,
    $$NotebooksTableAnnotationComposer,
    $$NotebooksTableCreateCompanionBuilder,
    $$NotebooksTableUpdateCompanionBuilder,
    (NotebookEntity, $$NotebooksTableReferences),
    NotebookEntity,
    PrefetchHooks Function({bool pagesRefs})>;
typedef $$PagesTableCreateCompanionBuilder = PagesCompanion Function({
  required String id,
  required String notebookId,
  required int pageIndex,
  Value<String?> backgroundType,
  Value<String?> thumbnailPath,
  Value<int> rowid,
});
typedef $$PagesTableUpdateCompanionBuilder = PagesCompanion Function({
  Value<String> id,
  Value<String> notebookId,
  Value<int> pageIndex,
  Value<String?> backgroundType,
  Value<String?> thumbnailPath,
  Value<int> rowid,
});

final class $$PagesTableReferences
    extends BaseReferences<_$AppDatabase, $PagesTable, PageEntity> {
  $$PagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotebooksTable _notebookIdTable(_$AppDatabase db) =>
      db.notebooks.createAlias('pages__notebook_id__notebooks__id');

  $$NotebooksTableProcessedTableManager get notebookId {
    final $_column = $_itemColumn<String>('notebook_id')!;

    final manager = $$NotebooksTableTableManager($_db, $_db.notebooks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_notebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$StrokesTable, List<StrokeEntity>>
      _strokesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.strokes,
              aliasName: 'pages__id__strokes__page_id');

  $$StrokesTableProcessedTableManager get strokesRefs {
    final manager = $$StrokesTableTableManager($_db, $_db.strokes)
        .filter((f) => f.pageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_strokesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PagesTableFilterComposer extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backgroundType => $composableBuilder(
      column: $table.backgroundType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  $$NotebooksTableFilterComposer get notebookId {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.notebookId,
        referencedTable: $db.notebooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotebooksTableFilterComposer(
              $db: $db,
              $table: $db.notebooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> strokesRefs(
      Expression<bool> Function($$StrokesTableFilterComposer f) f) {
    final $$StrokesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.strokes,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StrokesTableFilterComposer(
              $db: $db,
              $table: $db.strokes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PagesTableOrderingComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backgroundType => $composableBuilder(
      column: $table.backgroundType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  $$NotebooksTableOrderingComposer get notebookId {
    final $$NotebooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.notebookId,
        referencedTable: $db.notebooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotebooksTableOrderingComposer(
              $db: $db,
              $table: $db.notebooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<String> get backgroundType => $composableBuilder(
      column: $table.backgroundType, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  $$NotebooksTableAnnotationComposer get notebookId {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.notebookId,
        referencedTable: $db.notebooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotebooksTableAnnotationComposer(
              $db: $db,
              $table: $db.notebooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> strokesRefs<T extends Object>(
      Expression<T> Function($$StrokesTableAnnotationComposer a) f) {
    final $$StrokesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.strokes,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StrokesTableAnnotationComposer(
              $db: $db,
              $table: $db.strokes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PagesTable,
    PageEntity,
    $$PagesTableFilterComposer,
    $$PagesTableOrderingComposer,
    $$PagesTableAnnotationComposer,
    $$PagesTableCreateCompanionBuilder,
    $$PagesTableUpdateCompanionBuilder,
    (PageEntity, $$PagesTableReferences),
    PageEntity,
    PrefetchHooks Function({bool notebookId, bool strokesRefs})> {
  $$PagesTableTableManager(_$AppDatabase db, $PagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> notebookId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<String?> backgroundType = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PagesCompanion(
            id: id,
            notebookId: notebookId,
            pageIndex: pageIndex,
            backgroundType: backgroundType,
            thumbnailPath: thumbnailPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String notebookId,
            required int pageIndex,
            Value<String?> backgroundType = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PagesCompanion.insert(
            id: id,
            notebookId: notebookId,
            pageIndex: pageIndex,
            backgroundType: backgroundType,
            thumbnailPath: thumbnailPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({notebookId = false, strokesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (strokesRefs) db.strokes],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (notebookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.notebookId,
                    referencedTable:
                        $$PagesTableReferences._notebookIdTable(db),
                    referencedColumn:
                        $$PagesTableReferences._notebookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (strokesRefs)
                    await $_getPrefetchedData<PageEntity, $PagesTable,
                            StrokeEntity>(
                        currentTable: table,
                        referencedTable:
                            $$PagesTableReferences._strokesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagesTableReferences(db, table, p0).strokesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.pageId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PagesTable,
    PageEntity,
    $$PagesTableFilterComposer,
    $$PagesTableOrderingComposer,
    $$PagesTableAnnotationComposer,
    $$PagesTableCreateCompanionBuilder,
    $$PagesTableUpdateCompanionBuilder,
    (PageEntity, $$PagesTableReferences),
    PageEntity,
    PrefetchHooks Function({bool notebookId, bool strokesRefs})>;
typedef $$StrokesTableCreateCompanionBuilder = StrokesCompanion Function({
  required String id,
  required String pageId,
  required String brushSettingsJson,
  required int colorValue,
  required String boundingBoxJson,
  required Uint8List geometryBlob,
  Value<int> rowid,
});
typedef $$StrokesTableUpdateCompanionBuilder = StrokesCompanion Function({
  Value<String> id,
  Value<String> pageId,
  Value<String> brushSettingsJson,
  Value<int> colorValue,
  Value<String> boundingBoxJson,
  Value<Uint8List> geometryBlob,
  Value<int> rowid,
});

final class $$StrokesTableReferences
    extends BaseReferences<_$AppDatabase, $StrokesTable, StrokeEntity> {
  $$StrokesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PagesTable _pageIdTable(_$AppDatabase db) =>
      db.pages.createAlias('strokes__page_id__pages__id');

  $$PagesTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<String>('page_id')!;

    final manager = $$PagesTableTableManager($_db, $_db.pages)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StrokesTableFilterComposer
    extends Composer<_$AppDatabase, $StrokesTable> {
  $$StrokesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brushSettingsJson => $composableBuilder(
      column: $table.brushSettingsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boundingBoxJson => $composableBuilder(
      column: $table.boundingBoxJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get geometryBlob => $composableBuilder(
      column: $table.geometryBlob, builder: (column) => ColumnFilters(column));

  $$PagesTableFilterComposer get pageId {
    final $$PagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableFilterComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StrokesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrokesTable> {
  $$StrokesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brushSettingsJson => $composableBuilder(
      column: $table.brushSettingsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boundingBoxJson => $composableBuilder(
      column: $table.boundingBoxJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get geometryBlob => $composableBuilder(
      column: $table.geometryBlob,
      builder: (column) => ColumnOrderings(column));

  $$PagesTableOrderingComposer get pageId {
    final $$PagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableOrderingComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StrokesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrokesTable> {
  $$StrokesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brushSettingsJson => $composableBuilder(
      column: $table.brushSettingsJson, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<String> get boundingBoxJson => $composableBuilder(
      column: $table.boundingBoxJson, builder: (column) => column);

  GeneratedColumn<Uint8List> get geometryBlob => $composableBuilder(
      column: $table.geometryBlob, builder: (column) => column);

  $$PagesTableAnnotationComposer get pageId {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableAnnotationComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StrokesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StrokesTable,
    StrokeEntity,
    $$StrokesTableFilterComposer,
    $$StrokesTableOrderingComposer,
    $$StrokesTableAnnotationComposer,
    $$StrokesTableCreateCompanionBuilder,
    $$StrokesTableUpdateCompanionBuilder,
    (StrokeEntity, $$StrokesTableReferences),
    StrokeEntity,
    PrefetchHooks Function({bool pageId})> {
  $$StrokesTableTableManager(_$AppDatabase db, $StrokesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrokesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrokesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrokesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> pageId = const Value.absent(),
            Value<String> brushSettingsJson = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<String> boundingBoxJson = const Value.absent(),
            Value<Uint8List> geometryBlob = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StrokesCompanion(
            id: id,
            pageId: pageId,
            brushSettingsJson: brushSettingsJson,
            colorValue: colorValue,
            boundingBoxJson: boundingBoxJson,
            geometryBlob: geometryBlob,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String pageId,
            required String brushSettingsJson,
            required int colorValue,
            required String boundingBoxJson,
            required Uint8List geometryBlob,
            Value<int> rowid = const Value.absent(),
          }) =>
              StrokesCompanion.insert(
            id: id,
            pageId: pageId,
            brushSettingsJson: brushSettingsJson,
            colorValue: colorValue,
            boundingBoxJson: boundingBoxJson,
            geometryBlob: geometryBlob,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$StrokesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({pageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (pageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pageId,
                    referencedTable: $$StrokesTableReferences._pageIdTable(db),
                    referencedColumn:
                        $$StrokesTableReferences._pageIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StrokesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StrokesTable,
    StrokeEntity,
    $$StrokesTableFilterComposer,
    $$StrokesTableOrderingComposer,
    $$StrokesTableAnnotationComposer,
    $$StrokesTableCreateCompanionBuilder,
    $$StrokesTableUpdateCompanionBuilder,
    (StrokeEntity, $$StrokesTableReferences),
    StrokeEntity,
    PrefetchHooks Function({bool pageId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$StrokesTableTableManager get strokes =>
      $$StrokesTableTableManager(_db, _db.strokes);
}
