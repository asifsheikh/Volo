import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_circle_contact.freezed.dart';
part 'my_circle_contact.g.dart';

@freezed
class MyCircleContact with _$MyCircleContact {
  const factory MyCircleContact({
    required String id,
    required String name,
    required String whatsappNumber,
    required String timezone,
    required String language,
  }) = _MyCircleContact;

  factory MyCircleContact.fromJson(Map<String, dynamic> json) => _$MyCircleContactFromJson(json);
}

@freezed
class MyCircleContactForm with _$MyCircleContactForm {
  const factory MyCircleContactForm({
    required String name,
    required String whatsappNumber,
    required String timezone,
    required String language,
  }) = _MyCircleContactForm;
}
