import '../../domain/entities/my_circle_contact.dart';

class MyCircleContactModel extends MyCircleContact {
  const MyCircleContactModel({
    required super.id,
    required super.name,
    required super.whatsappNumber,
    required super.timezone,
    required super.language,
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

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'whatsappNumber': whatsappNumber,
      'timezone': timezone,
      'language': language,
    };
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
