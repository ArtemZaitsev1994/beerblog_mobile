// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarData _$BarDataFromJson(Map<String, dynamic> json) {
  return BarData(
    bar: (json['bar'] as List)
        ?.map((e) => e == null ? null : Bar.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    pagination: json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BarDataToJson(BarData instance) => <String, dynamic>{
      'bar': instance.bar,
      'pagination': instance.pagination,
    };

BarDataItem _$BarDataItemFromJson(Map<String, dynamic> json) {
  return BarDataItem(
    bar: json['bar'] == null
        ? null
        : Bar.fromJson(json['bar'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BarDataItemToJson(BarDataItem instance) =>
    <String, dynamic>{
      'bar': instance.bar,
    };

Bar _$BarFromJson(Map<String, dynamic> json) {
  return Bar(
    barId: json['_id'] as String,
    name: json['name'] as String,
    rate: json['rate'] as int,
    review: json['review'] as String,
    photos: json['photos'] as Map<String, dynamic>,
    worktime: json['worktime'] as String,
    address: json['address'] as String,
    site: json['site'] as String,
    postedBy: json['postedBy'] as String,
    avatar: json['avatar'] as String,
    mini_avatar: json['mini_avatar'] as String,
    rates: (json['rates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    comments: (json['comments'] as List)
        ?.map((e) => e as Map<String, dynamic>)
        ?.toList(),
    city: json['city'] as String,
    country: json['country'] as String,
  );
}

Map<String, dynamic> _$BarToJson(Bar instance) => <String, dynamic>{
      '_id': instance.barId,
      'name': instance.name,
      'rate': instance.rate,
      'review': instance.review,
      'address': instance.address,
      'site': instance.site,
      'city': instance.city,
      'country': instance.country,
      'avatar': instance.avatar,
      'worktime': instance.worktime,
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
