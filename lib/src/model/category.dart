// class CategoryModel {
//   final int id;
//   final String name;
//   final String url;
//   final List<CategoryModel>? childs;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.url,
//     this.childs,
//   });

//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     var childsJson = json['childs'] as List<dynamic>?;

//     return CategoryModel(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       url: json['url'] as String,
//       childs: childsJson != null
//           ? childsJson
//               .map((childJson) => CategoryModel.fromJson(childJson))
//               .toList()
//           : null,
//     );
//   }
// }

class CategoryModel {
  final int? id;
  final String? name;
  final String? url;
  final String? parentId;
  final int? createDate;
  final int? updatedDate;

  CategoryModel({
    this.id,
    this.name,
    this.url,
    this.parentId,
    this.createDate,
    this.updatedDate,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        url: json["url"],
        parentId: json["parent_id"],
        createDate: json["create_date"],
        updatedDate: json["updated_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
        "parent_id": parentId,
        "create_date": createDate,
        "updated_date": updatedDate,
      };
}
