// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUsageStatsCollection on Isar {
  IsarCollection<UsageStats> get usageStats => this.collection();
}

const UsageStatsSchema = CollectionSchema(
  name: r'UsageStats',
  id: 266619259051503790,
  properties: {
    r'aiScanCount': PropertySchema(
      id: 0,
      name: r'aiScanCount',
      type: IsarType.long,
    ),
    r'periodKey': PropertySchema(
      id: 1,
      name: r'periodKey',
      type: IsarType.string,
    ),
    r'periodStartedAt': PropertySchema(
      id: 2,
      name: r'periodStartedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _usageStatsEstimateSize,
  serialize: _usageStatsSerialize,
  deserialize: _usageStatsDeserialize,
  deserializeProp: _usageStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _usageStatsGetId,
  getLinks: _usageStatsGetLinks,
  attach: _usageStatsAttach,
  version: '3.1.0+1',
);

int _usageStatsEstimateSize(
  UsageStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.periodKey.length * 3;
  return bytesCount;
}

void _usageStatsSerialize(
  UsageStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.aiScanCount);
  writer.writeString(offsets[1], object.periodKey);
  writer.writeDateTime(offsets[2], object.periodStartedAt);
}

UsageStats _usageStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UsageStats();
  object.aiScanCount = reader.readLong(offsets[0]);
  object.id = id;
  object.periodKey = reader.readString(offsets[1]);
  object.periodStartedAt = reader.readDateTimeOrNull(offsets[2]);
  return object;
}

P _usageStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _usageStatsGetId(UsageStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _usageStatsGetLinks(UsageStats object) {
  return [];
}

void _usageStatsAttach(IsarCollection<dynamic> col, Id id, UsageStats object) {
  object.id = id;
}

extension UsageStatsQueryWhereSort
    on QueryBuilder<UsageStats, UsageStats, QWhere> {
  QueryBuilder<UsageStats, UsageStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UsageStatsQueryWhere
    on QueryBuilder<UsageStats, UsageStats, QWhereClause> {
  QueryBuilder<UsageStats, UsageStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UsageStatsQueryFilter
    on QueryBuilder<UsageStats, UsageStats, QFilterCondition> {
  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      aiScanCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiScanCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      aiScanCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiScanCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      aiScanCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiScanCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      aiScanCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiScanCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> periodKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> periodKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> periodKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'periodKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> periodKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'periodKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> periodKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'periodKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition> periodKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'periodKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'periodKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodStartedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'periodStartedAt',
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodStartedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'periodStartedAt',
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodStartedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodStartedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodStartedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterFilterCondition>
      periodStartedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodStartedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UsageStatsQueryObject
    on QueryBuilder<UsageStats, UsageStats, QFilterCondition> {}

extension UsageStatsQueryLinks
    on QueryBuilder<UsageStats, UsageStats, QFilterCondition> {}

extension UsageStatsQuerySortBy
    on QueryBuilder<UsageStats, UsageStats, QSortBy> {
  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> sortByAiScanCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiScanCount', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> sortByAiScanCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiScanCount', Sort.desc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> sortByPeriodKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> sortByPeriodKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.desc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> sortByPeriodStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStartedAt', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy>
      sortByPeriodStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStartedAt', Sort.desc);
    });
  }
}

extension UsageStatsQuerySortThenBy
    on QueryBuilder<UsageStats, UsageStats, QSortThenBy> {
  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenByAiScanCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiScanCount', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenByAiScanCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiScanCount', Sort.desc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenByPeriodKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenByPeriodKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.desc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy> thenByPeriodStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStartedAt', Sort.asc);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QAfterSortBy>
      thenByPeriodStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStartedAt', Sort.desc);
    });
  }
}

extension UsageStatsQueryWhereDistinct
    on QueryBuilder<UsageStats, UsageStats, QDistinct> {
  QueryBuilder<UsageStats, UsageStats, QDistinct> distinctByAiScanCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiScanCount');
    });
  }

  QueryBuilder<UsageStats, UsageStats, QDistinct> distinctByPeriodKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageStats, UsageStats, QDistinct> distinctByPeriodStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodStartedAt');
    });
  }
}

extension UsageStatsQueryProperty
    on QueryBuilder<UsageStats, UsageStats, QQueryProperty> {
  QueryBuilder<UsageStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UsageStats, int, QQueryOperations> aiScanCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiScanCount');
    });
  }

  QueryBuilder<UsageStats, String, QQueryOperations> periodKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodKey');
    });
  }

  QueryBuilder<UsageStats, DateTime?, QQueryOperations>
      periodStartedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodStartedAt');
    });
  }
}
