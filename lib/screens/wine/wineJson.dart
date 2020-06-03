import 'package:json_annotation/json_annotation.dart';

part 'wineJson.g.dart';


@JsonSerializable()
class WineData {
  List<Wine> wine;
  Pagination pagination;

  WineData({this.wine, this.pagination});

  factory WineData.fromJson(Map<String, dynamic> json) => _$WineDataFromJson(json);
  Map<String, dynamic> toJson() => _$WineDataToJson(this);
}

@JsonSerializable()
class WineDataItem {
  Wine wine;

  WineDataItem({this.wine});

  factory WineDataItem.fromJson(Map<String, dynamic> json) => _$WineDataItemFromJson(json);
  Map<String, dynamic> toJson() => _$WineDataItemToJson(this);
}

@JsonSerializable()
class Wine {
  @JsonKey(name: '_id')
  final String wineId;
  final String name;
  final int rate;
  final String manufacturer;
  final String review;
  final String others;
  final String sugar;
  final String style;
  final double alcohol;
  final String avatar;
  final String mini_avatar;
  final Map<String, dynamic> photos;
  final List<Map> comments;
  final Map<String, int> rates;
  final String postedBy;

  Wine({
    this.wineId, this.name, this.rate,
    this.manufacturer, this.review, this.others,
    this.alcohol, this.avatar, this.mini_avatar,
    this.photos, this.comments, this.rates,
    this.postedBy, this.style, this.sugar
  });

  factory Wine.fromJson(Map<String, dynamic> json) => _$WineFromJson(json);
  Map<String, dynamic> toJson() => _$WineToJson(this);
}


@JsonSerializable()
class Pagination {
  @JsonKey(name: 'has_next')
  final bool hasNext;
  final int next;
  final int prev;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int max;

  Pagination({
    this.hasNext, this.next, this.prev, this.page, this.perPage, this.max
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
