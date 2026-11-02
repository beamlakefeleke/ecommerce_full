import 'package:equatable/equatable.dart';

/// Pure domain entity for a category or sub-category.
class Category extends Equatable {
  final int? id;
  final String? name;
  final int? parentId;
  final int? position;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const Category({
    this.id,
    this.name,
    this.parentId,
    this.position,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, parentId, position, image];
}
