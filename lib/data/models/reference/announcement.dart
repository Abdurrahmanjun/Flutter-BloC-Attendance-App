import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

/// `GET /api/announcements` — the home carousel, replacing the local
/// `promoImagePaths` asset list.
@JsonSerializable()
class Announcement {
  final int id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final DateTime publishedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.publishedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}
