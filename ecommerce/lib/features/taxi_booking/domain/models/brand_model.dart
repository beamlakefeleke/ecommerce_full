import '../entities/brand.dart';

class BrandModel extends Brand {
  BrandModel({
    super.id,
    super.moduleId,
    super.name,
    super.logo,
    super.description,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'],
      moduleId: json['module_id'],
      name: json['name'],
      logo: json['logo'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'name': name,
      'logo': logo,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}