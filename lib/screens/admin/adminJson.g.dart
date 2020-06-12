// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adminJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPanel _$AdminPanelFromJson(Map<String, dynamic> json) {
  return AdminPanel(
    items: (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Item.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AdminPanelToJson(AdminPanel instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    itemType: json['itemType'] as String,
    notConfirmed: json['notConfirmed'] as int,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'itemType': instance.itemType,
      'notConfirmed': instance.notConfirmed,
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

AdminItemsList _$AdminItemsListFromJson(Map<String, dynamic> json) {
  return AdminItemsList(
    json['items'] as List,
    json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AdminItemsListToJson(AdminItemsList instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };
