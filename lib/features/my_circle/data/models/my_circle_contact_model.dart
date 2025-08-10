import '../../domain/entities/my_circle_contact.dart';

class MyCircleContactModel extends MyCircleContact {
  const MyCircleContactModel({
    required super.id,
    required super.name,
    required super.whatsappNumber,
    required super.timezone,
    required super.language,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory MyCircleContactModel.fromJson(Map<String, dynamic> json) {
    return MyCircleContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      whatsappNumber: json['whatsappNumber'] as String,
      timezone: json['timezone'] as String,
      language: json['language'] as String,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory MyCircleContactModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MyCircleContactModel(
      id: id,
      name: data['name'] as String,
      whatsappNumber: data['whatsappNumber'] as String,
      timezone: data['timezone'] as String,
      language: data['language'] as String,
      isActive: data['isActive'] as bool? ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as dynamic).toDate() as DateTime
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as dynamic).toDate() as DateTime
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'whatsappNumber': whatsappNumber,
      'timezone': timezone,
      'language': language,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  MyCircleContactModel copyWith({
    String? id,
    String? name,
    String? whatsappNumber,
    String? timezone,
    String? language,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MyCircleContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
