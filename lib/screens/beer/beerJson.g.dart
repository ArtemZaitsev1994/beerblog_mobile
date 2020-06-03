// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beerJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeerData _$BeerDataFromJson(Map<String, dynamic> json) {
  return BeerData(
    beer: (json['beer'] as List)
        ?.map(
            (e) => e == null ? null : Beer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    pagination: json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BeerDataToJson(BeerData instance) => <String, dynamic>{
      'beer': instance.beer,
      'pagination': instance.pagination,
    };

BeerDataItem _$BeerDataItemFromJson(Map<String, dynamic> json) {
  return BeerDataItem(
    beer: json['beer'] == null
        ? null
        : Beer.fromJson(json['beer'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BeerDataItemToJson(BeerDataItem instance) =>
    <String, dynamic>{
      'beer': instance.beer,
    };

Beer _$BeerFromJson(Map<String, dynamic> json) {
  return Beer(
    beerId: json['_id'] as String,
    name: json['name'] as String,
    rate: json['rate'] as int,
    manufacturer: json['manufacturer'] as String,
    review: json['review'] as String,
    others: json['others'] as String,
    fortress: (json['fortress'] as num)?.toDouble(),
    ibu: json['ibu'],
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
  );
}

Map<String, dynamic> _$BeerToJson(Beer instance) => <String, dynamic>{
      '_id': instance.beerId,
      'name': instance.name,
      'rate': instance.rate,
      'manufacturer': instance.manufacturer,
      'review': instance.review,
      'others': instance.others,
      'fortress': instance.fortress,
      'ibu': instance.ibu,
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
