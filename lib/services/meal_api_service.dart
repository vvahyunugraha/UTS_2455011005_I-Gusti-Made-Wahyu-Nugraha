import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // GET: Kategori Resep
  Future<List<MealCategory>> fetchCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categoriesJson = data['categories'] ?? [];
      return categoriesJson.map((json) => MealCategory.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat kategori resep (Status: ${response.statusCode})');
    }
  }

  // GET: Cari Resep berdasarkan Nama / Keyword
  Future<List<Meal>> searchMeals(String query) async {
    final url = query.trim().isEmpty
        ? '$_baseUrl/search.php?s=chicken' // default keyword populer
        : '$_baseUrl/search.php?s=$query';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson == null) {
        return [];
      }
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mencari resep (Status: ${response.statusCode})');
    }
  }

  // GET: Filter Resep berdasarkan Kategori
  Future<List<Meal>> filterByCategory(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson == null) {
        return [];
      }
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memfilter resep (Status: ${response.statusCode})');
    }
  }

  // GET: Detail Lengkap Resep berdasarkan ID
  Future<Meal> fetchMealDetail(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson != null && mealsJson.isNotEmpty) {
        return Meal.fromJson(mealsJson.first);
      }
      throw Exception('Resep tidak ditemukan');
    } else {
      throw Exception('Gagal memuat detail resep (Status: ${response.statusCode})');
    }
  }

  // GET: Resep Acak (Meal of The Day)
  Future<Meal> fetchRandomMeal() async {
    final response = await http.get(Uri.parse('$_baseUrl/random.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson != null && mealsJson.isNotEmpty) {
        return Meal.fromJson(mealsJson.first);
      }
      throw Exception('Gagal mengambil resep rekomendasi');
    } else {
      throw Exception('Gagal memuat resep rekomendasi (Status: ${response.statusCode})');
    }
  }
}
