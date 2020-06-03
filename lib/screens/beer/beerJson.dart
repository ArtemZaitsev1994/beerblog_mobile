import 'package:json_annotation/json_annotation.dart';

part 'beerJson.g.dart';


@JsonSerializable()
class BeerData {
  List<Beer> beer;
  Pagination pagination;

  BeerData({this.beer, this.pagination});


  factory BeerData.fromJson(Map<String, dynamic> json) => _$BeerDataFromJson(json);

  Map<String, dynamic> toJson() => _$BeerDataToJson(this);
}

@JsonSerializable()
class BeerDataItem {
  Beer beer;

  BeerDataItem({this.beer});


  factory BeerDataItem.fromJson(Map<String, dynamic> json) => _$BeerDataItemFromJson(json);

  Map<String, dynamic> toJson() => _$BeerDataItemToJson(this);
}

@JsonSerializable()
class Beer {
  @JsonKey(name: '_id')
  final String beerId;
  final String name;
  final int rate;
  final String manufacturer;
  final String review;
  final String others;
  final double fortress;
  final dynamic ibu;
  final double alcohol;
  final String avatar;
  final String mini_avatar;
  final Map<String, dynamic> photos;
  final List<Map> comments;
  final Map<String, int> rates;
  final String postedBy;

  Beer({
    this.beerId, this.name, this.rate,
    this.manufacturer, this.review, this.others,
    this.fortress, this.ibu, this.alcohol,
    this.avatar, this.mini_avatar, this.photos,
    this.comments, this.rates, this.postedBy
  });

  factory Beer.fromJson(Map<String, dynamic> json) => _$BeerFromJson(json);

  Map<String, dynamic> toJson() => _$BeerToJson(this);
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
