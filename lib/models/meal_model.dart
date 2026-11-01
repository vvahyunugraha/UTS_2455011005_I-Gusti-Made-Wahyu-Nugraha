class MealCategory {
  final String id;
  final String name;
  final String thumbnail;
  final String description;

  MealCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbnail: json['strCategoryThumb'] ?? '',
      description: json['strCategoryDescription'] ?? '',
    );
  }
}

class IngredientItem {
  final String ingredient;
  final String measure;

  IngredientItem({required this.ingredient, required this.measure});
}

class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String? youtubeUrl;
  final List<String> tags;
  final List<IngredientItem> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    this.youtubeUrl,
    required this.tags,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final List<IngredientItem> extractedIngredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty &&
          ingredient.toString().trim() != '') {
        extractedIngredients.add(
          IngredientItem(
            ingredient: ingredient.toString().trim(),
            measure: (measure != null && measure.toString().trim().isNotEmpty)
                ? measure.toString().trim()
                : '',
          ),
        );
      }
    }

    final rawTags = json['strTags'] as String?;
    final tagList = rawTags != null && rawTags.isNotEmpty
        ? rawTags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown Recipe',
      category: json['strCategory'] ?? 'General',
      area: json['strArea'] ?? 'International',
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      tags: tagList,
      ingredients: extractedIngredients,
    );
  }
}

