import '../models/meal_model.dart';
import '../services/meal_api_service.dart';

class MealRepository {
  final MealApiService _apiService;

  MealRepository({MealApiService? apiService})
      : _apiService = apiService ?? MealApiService();

  Future<List<MealCategory>> getCategories() async {
    return await _apiService.fetchCategories();
  }

  Future<List<Meal>> searchMeals(String query) async {
    return await _apiService.searchMeals(query);
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    return await _apiService.filterByCategory(category);
  }

  Future<Meal> getMealDetail(String id) async {
    return await _apiService.fetchMealDetail(id);
  }

  Future<Meal> getRandomMeal() async {
    return await _apiService.fetchRandomMeal();
  }
}

