import '../../domain/entities/my_circle_contact.dart';

class MyCircleContactModel {
  final String id;
  final String name;
  final String whatsappNumber;
  final String timezone;
  final String language;

  const MyCircleContactModel({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    required this.timezone,
    required this.language,
  });

  factory MyCircleContactModel.fromJson(Map<String, dynamic> json) {
    return MyCircleContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      whatsappNumber: json['whatsappNumber'] as String,
      timezone: json['timezone'] as String,
      language: json['language'] as String,
    );
  }

  factory MyCircleContactModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MyCircleContactModel(
      id: id,
      name: data['name'] as String,
      whatsappNumber: data['whatsappNumber'] as String,
      timezone: data['timezone'] as String,
      language: data['language'] as String,
    );
  }

  factory MyCircleContactModel.fromEntity(MyCircleContact entity) {
    return MyCircleContactModel(
      id: entity.id,
      name: entity.name,
      whatsappNumber: entity.whatsappNumber,
      timezone: entity.timezone,
      language: entity.language,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'whatsappNumber': whatsappNumber,
      'timezone': timezone,
      'language': language,
    };
  }

  MyCircleContact toEntity() {
    return MyCircleContact(
      id: id,
      name: name,
      whatsappNumber: whatsappNumber,
      timezone: timezone,
      language: language,
    );
  }

  MyCircleContactModel copyWith({
    String? id,
    String? name,
    String? whatsappNumber,
    String? timezone,
    String? language,
  }) {
    return MyCircleContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
    );
  }
}
