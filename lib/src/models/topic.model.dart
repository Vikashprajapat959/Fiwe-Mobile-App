/// Topic model representing discussion topics in the application
class Topic {
  const Topic({
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
    this.isPrimary,
    this.category,
    this.tags,
    this.activityLevel,
    this.isPopular,
    this.createdAt,
    this.updatedAt,
    this.lastActivityAt,
  });

  /// Creates a Topic from JSON data
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      isPrimary: json['is_primary'] as bool?,
      peopleCount: json['people_count'] as int?,
      viewCount: json['view_count'] as int?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
      isEnabled: json['is_enabled'] as bool?,
      isFeatured: json['is_featured'] as bool?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((dynamic e) => e as String)
          .toList(),
      activityLevel: json['activity_level'] as String?,
      isPopular: json['is_popular'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.tryParse(json['last_activity_at'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String? avatar;
  final int? peopleCount;
  final int? viewCount;
  final double? popularityScore;
  final bool? isEnabled;
  final bool? isFeatured;
  final String? category;
  final List<String>? tags;
  final String? activityLevel;
  final bool? isPrimary;
  final bool? isPopular;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActivityAt;

  /// Converts Topic to JSON format
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
      'is_primary': isPrimary,
      'category': category,
      'tags': tags,
      'activity_level': activityLevel,
      'is_popular': isPopular,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this topic with updated values
  Topic copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    String? avatar,
    int? peopleCount,
    int? viewCount,
    double? popularityScore,
    bool? isEnabled,
    bool? isFeatured,
    bool? isPrimary,
    String? category,
    List<String>? tags,
    String? activityLevel,
    bool? isPopular,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      peopleCount: peopleCount ?? this.peopleCount,
      viewCount: viewCount ?? this.viewCount,
      popularityScore: popularityScore ?? this.popularityScore,
      isEnabled: isEnabled ?? this.isEnabled,
      isFeatured: isFeatured ?? this.isFeatured,
      isPrimary: isPrimary ?? this.isPrimary,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      activityLevel: activityLevel ?? this.activityLevel,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Topic(id: $id, title: $title)';
}
