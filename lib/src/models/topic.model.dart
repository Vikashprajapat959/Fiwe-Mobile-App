//  "topics": [
//       {
//         "id": "39ac11c4-dfe0-4bb8-b081-cdefef077f4d",
//         "title": "Movies",
//         "slug": "movies",
//         "description": "Love it",
//         "avatar": "",
//         "people_count": 0,
//         "view_count": 0,
//         "popularity_score": 0,
//         "is_enabled": true,
//         "is_featured": false,
//         "category": null,
//         "tags": [],
//         "activity_level": "Very Low",
//         "is_popular": false,
//         "created_at": "2025-09-02T09:01:18.841609Z",
//         "updated_at": "2025-09-02T09:01:18.841627Z",
//         "last_activity_at": "2025-09-02T09:01:18.833546Z"
//       }
//     ],
class Topic {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String? avatar;
  final int? peopleCount;
  final int? viewCount;
  final int? popularityScore;
  final bool? isEnabled;
  final bool? isFeatured;
  final String? category;
  final List<String>? tags;
  final String? activityLevel;
  final bool? isPopular;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;

  Topic({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.avatar,
    this.peopleCount,
    this.viewCount,
    this.popularityScore,
    this.isEnabled,
    this.isFeatured,
    this.category,
    this.tags,
    this.activityLevel,
    this.isPopular,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      avatar: json['avatar'] as String,
      peopleCount: json['people_count'] as int,
      viewCount: json['view_count'] as int,
      popularityScore: json['popularity_score'] as int,
      isEnabled: json['is_enabled'] as bool,
      isFeatured: json['is_featured'] as bool,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      activityLevel: json['activity_level'] as String,
      isPopular: json['is_popular'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'avatar': avatar,
      'people_count': peopleCount,
      'view_count': viewCount,
      'popularity_score': popularityScore,
      'is_enabled': isEnabled,
      'is_featured': isFeatured,
      'category': category,
      'tags': tags,
      'activity_level': activityLevel,
      'is_popular': isPopular,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_activity_at': lastActivityAt.toIso8601String(),
    };
  }
}
