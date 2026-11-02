import 'package:ecommerce/features/category/domain/entities/category.dart';

/// Single serializable model for a category. Owns fromJson/toJson/toEntity.
class CategoryModel {
  int? id;
  String? name;
  int? parentId;
  int? position;
  String? createdAt;
  String? updatedAt;
  String? image;

  CategoryModel({
    this.id,
    this.name,
    this.parentId,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentId = json['parent_id'];
    position = json['position'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parent_id': parentId,
    'position': position,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'image': image,
  };

  Category toEntity() => Category(
    id: id,
    name: name,
    parentId: parentId,
    position: position,
    image: image,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory CategoryModel.fromEntity(Category e) => CategoryModel(
    id: e.id,
    name: e.name,
    parentId: e.parentId,
    position: e.position,
    image: e.image,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}
