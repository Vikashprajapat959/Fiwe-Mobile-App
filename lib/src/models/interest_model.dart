import 'dart:convert';

import 'package:flutter/material.dart';

/// Model representing user interest categories
class InterestModel {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final Color backgroundColor;
  final bool isSelected;

  const InterestModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.backgroundColor,
    this.isSelected = false,
  });

  /// Create a copy with modified properties
  InterestModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconEmoji,
    Color? backgroundColor,
    bool? isSelected,
  }) {
    return InterestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconEmoji': iconEmoji,
      'backgroundColor': backgroundColor.value,
      'isSelected': isSelected,
    };
  }

  /// Create from JSON
  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconEmoji: json['iconEmoji'] as String,
      backgroundColor: Color(json['backgroundColor'] as int),
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  /// Convert to string for storage (JSON string)
  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Predefined interest categories with emojis and colors
  static List<InterestModel> get predefinedInterests => [
    InterestModel(
      id: 'technology',
      name: 'Technology',
      description: 'Programming, gadgets, innovation',
      iconEmoji: '💻',
      backgroundColor: const Color(0xFF3B82F6), // Blue
    ),
    InterestModel(
      id: 'sports',
      name: 'Sports',
      description: 'Football, basketball, fitness',
      iconEmoji: '⚽',
      backgroundColor: const Color(0xFF10B981), // Green
    ),
    InterestModel(
      id: 'music',
      name: 'Music',
      description: 'All genres and instruments',
      iconEmoji: '🎵',
      backgroundColor: const Color(0xFF8B5CF6), // Purple
    ),
    InterestModel(
      id: 'travel',
      name: 'Travel',
      description: 'Destinations and experiences',
      iconEmoji: '✈️',
      backgroundColor: const Color(0xFFF59E0B), // Amber
    ),
    InterestModel(
      id: 'food',
      name: 'Food',
      description: 'Cooking, restaurants, cuisine',
      iconEmoji: '🍔',
      backgroundColor: const Color(0xFFEF4444), // Red
    ),
    InterestModel(
      id: 'art',
      name: 'Art',
      description: 'Visual arts, design, creativity',
      iconEmoji: '🎨',
      backgroundColor: const Color(0xFFEC4899), // Pink
    ),
    InterestModel(
      id: 'books',
      name: 'Books',
      description: 'Literature, reading, education',
      iconEmoji: '📚',
      backgroundColor: const Color(0xFF06B6D4), // Cyan
    ),
    InterestModel(
      id: 'gaming',
      name: 'Gaming',
      description: 'Video games, board games',
      iconEmoji: '🎮',
      backgroundColor: const Color(0xFF84CC16), // Lime
    ),
    InterestModel(
      id: 'health',
      name: 'Health',
      description: 'Wellness, fitness, medical',
      iconEmoji: '🏥',
      backgroundColor: const Color(0xFF14B8A6), // Teal
    ),
    InterestModel(
      id: 'business',
      name: 'Business',
      description: 'Entrepreneurship, finance',
      iconEmoji: '💼',
      backgroundColor: const Color(0xFF6366F1), // Indigo
    ),
    InterestModel(
      id: 'photography',
      name: 'Photography',
      description: 'Camera, editing, visual storytelling',
      iconEmoji: '📸',
      backgroundColor: const Color(0xFFF97316), // Orange
    ),
    InterestModel(
      id: 'movies',
      name: 'Movies',
      description: 'Cinema, series, entertainment',
      iconEmoji: '🎬',
      backgroundColor: const Color(0xFF7C3AED), // Violet
    ),
  ];
}