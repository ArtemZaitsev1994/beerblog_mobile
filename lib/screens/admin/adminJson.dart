import 'package:beerblog/screens/admin/adminItemsList.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adminJson.g.dart';


@JsonSerializable()
class AdminPanel {
  List<Item> items;

  AdminPanel({this.items});

  factory AdminPanel.fromJson(Map<String, dynamic> json) => _$AdminPanelFromJson(json);
  Map<String, dynamic> toJson() => _$AdminPanelToJson(this);
}

@JsonSerializable()
class Item {
  final String itemType;
  final int notConfirmed;
  final int total;

  Item({
    this.itemType, this.notConfirmed, this.total
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
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


@JsonSerializable()
class AdminItemsList {
  List<dynamic> items;
  Pagination pagination;

  AdminItemsList(this.items, this.pagination);

  factory AdminItemsList.fromJson(Map<String, dynamic> json) => _$AdminItemsListFromJson(json);
  Map<String, dynamic> toJson() => _$AdminItemsListToJson(this);
}