class SavedRecipe {
  final int? id;
  final String mealId;
  final String mealName;
  final String category;
  final String thumbnailUrl;
  final String difficultyLevel; // 'Mudah', 'Sedang', 'Sulit'
  final String cookStatus;      // 'Ingin Dicoba', 'Sudah Dimasak', 'Favorit'
  final double rating;          // 1.0 - 5.0
  final String personalTips;
  final DateTime createdAt;

  SavedRecipe({
    this.id,
    required this.mealId,
    required this.mealName,
    required this.category,
    required this.thumbnailUrl,
    this.difficultyLevel = 'Sedang',
    this.cookStatus = 'Ingin Dicoba',
    this.rating = 5.0,
    required this.personalTips,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'meal_id': mealId,
      'meal_name': mealName,
      'category': category,
      'thumbnail_url': thumbnailUrl,
      'difficulty_level': difficultyLevel,
      'cook_status': cookStatus,
      'rating': rating,
      'personal_tips': personalTips,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedRecipe.fromMap(Map<String, dynamic> map) {
    return SavedRecipe(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      mealId: map['meal_id'] ?? '',
      mealName: map['meal_name'] ?? '',
      category: map['category'] ?? 'General',
      thumbnailUrl: map['thumbnail_url'] ?? '',
      difficultyLevel: map['difficulty_level'] ?? 'Sedang',
      cookStatus: map['cook_status'] ?? 'Ingin Dicoba',
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : 5.0,
      personalTips: map['personal_tips'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  SavedRecipe copyWith({
    int? id,
    String? mealId,
    String? mealName,
    String? category,
    String? thumbnailUrl,
    String? difficultyLevel,
    String? cookStatus,
    double? rating,
    String? personalTips,
    DateTime? createdAt,
  }) {
    return SavedRecipe(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      mealName: mealName ?? this.mealName,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      cookStatus: cookStatus ?? this.cookStatus,
      rating: rating ?? this.rating,
      personalTips: personalTips ?? this.personalTips,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
