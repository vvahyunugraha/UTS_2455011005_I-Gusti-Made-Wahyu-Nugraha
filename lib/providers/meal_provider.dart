import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../repositories/meal_repository.dart';

class MealProvider with ChangeNotifier {
  final MealRepository _repository;

  MealProvider({MealRepository? repository})
      : _repository = repository ?? MealRepository();

  List<MealCategory> _categories = [];
  List<Meal> _meals = [];
  Meal? _randomMeal;
  Meal? _selectedMeal;

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<MealCategory> get categories => _categories;
  List<Meal> get meals => _meals;
  Meal? get randomMeal => _randomMeal;
  Meal? get selectedMeal => _selectedMeal;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Memuat data awal: Kategori, Resep Populer, dan Meal of The Day
  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.searchMeals(''),
        _repository.getRandomMeal(),
      ]);

      _categories = results[0] as List<MealCategory>;
      _meals = results[1] as List<Meal>;
      _randomMeal = results[2] as Meal;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pencarian Resep
  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meals = await _repository.searchMeals(query);
      _selectedCategory = 'All';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter Kategori
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (category == 'All') {
        _meals = await _repository.searchMeals('');
      } else {
        _meals = await _repository.getMealsByCategory(category);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Muat detail lengkap resep
  Future<void> loadMealDetail(String id) async {
    _isLoadingDetail = true;
    _selectedMeal = null;
    notifyListeners();

    try {
      _selectedMeal = await _repository.getMealDetail(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}
