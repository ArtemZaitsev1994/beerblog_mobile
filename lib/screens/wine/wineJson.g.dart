// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wineJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WineData _$WineDataFromJson(Map<String, dynamic> json) {
  return WineData(
    wine: (json['wine'] as List)
        ?.map(
            (e) => e == null ? null : Wine.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    pagination: json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$WineDataToJson(WineData instance) => <String, dynamic>{
      'wine': instance.wine,
      'pagination': instance.pagination,
    };

WineDataItem _$WineDataItemFromJson(Map<String, dynamic> json) {
  return WineDataItem(
    wine: json['wine'] == null
        ? null
        : Wine.fromJson(json['wine'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$WineDataItemToJson(WineDataItem instance) =>
    <String, dynamic>{
      'wine': instance.wine,
    };

Wine _$WineFromJson(Map<String, dynamic> json) {
  return Wine(
    wineId: json['_id'] as String,
    name: json['name'] as String,
    rate: json['rate'] as int,
    manufacturer: json['manufacturer'] as String,
    review: json['review'] as String,
    others: json['others'] as String,
    alcohol: (json['alcohol'] as num)?.toDouble(),
    avatar: json['avatar'] as String,
    mini_avatar: json['mini_avatar'] as String,
    photos: json['photos'] as Map<String, dynamic>,
    comments: (json['comments'] as List)
        ?.map((e) => e as Map<String, dynamic>)
        ?.toList(),
    rates: (json['rates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    postedBy: json['postedBy'] as String,
    style: json['style'] as String,
    sugar: json['sugar'] as String,
  );
}

Map<String, dynamic> _$WineToJson(Wine instance) => <String, dynamic>{
      '_id': instance.wineId,
      'name': instance.name,
      'rate': instance.rate,
      'manufacturer': instance.manufacturer,
      'review': instance.review,
      'others': instance.others,
      'sugar': instance.sugar,
      'style': instance.style,
      'alcohol': instance.alcohol,
      'avatar': instance.avatar,
      'mini_avatar': instance.mini_avatar,
      'photos': instance.photos,
      'comments': instance.comments,
      'rates': instance.rates,
      'postedBy': instance.postedBy,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return Pagination(
    hasNext: json['has_next'] as bool,
    next: json['next'] as int,
    prev: json['prev'] as int,
    page: json['page'] as int,
    perPage: json['per_page'] as int,
    max: json['max'] as int,
  );
}

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'has_next': instance.hasNext,
      'next': instance.next,
      'prev': instance.prev,
      'page': instance.page,
      'per_page': instance.perPage,
      'max': instance.max,
    };
