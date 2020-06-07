import 'package:json_annotation/json_annotation.dart';

part 'barJson.g.dart';


@JsonSerializable()
class BarData {
  List<Bar> bar;
  Pagination pagination;

  BarData({this.bar, this.pagination});

  factory BarData.fromJson(Map<String, dynamic> json) => _$BarDataFromJson(json);
  Map<String, dynamic> toJson() => _$BarDataToJson(this);
}

@JsonSerializable()
class BarDataItem {
  Bar bar;

  BarDataItem({this.bar});

  factory BarDataItem.fromJson(Map<String, dynamic> json) => _$BarDataItemFromJson(json);
  Map<String, dynamic> toJson() => _$BarDataItemToJson(this);
}

@JsonSerializable()
class Bar {
  @JsonKey(name: '_id')
  final String barId;
  final String name;
  final int rate;
  final String review;
  final String address;
  final String site;
  final String city;
  final String country;
  final String avatar;
  final String worktime;
  final String mini_avatar;
  final Map<String, dynamic> photos;
  final List<Map> comments;
  final Map<String, int> rates;
  final String postedBy;

  Bar({
    this.barId, this.name, this.rate,
    this.review, this.photos, this.worktime,
    this.address, this.site, this.postedBy,
    this.avatar, this.mini_avatar, this.rates,
    this.comments, this.city, this.country
  });

  factory Bar.fromJson(Map<String, dynamic> json) => _$BarFromJson(json);
  Map<String, dynamic> toJson() => _$BarToJson(this);
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
