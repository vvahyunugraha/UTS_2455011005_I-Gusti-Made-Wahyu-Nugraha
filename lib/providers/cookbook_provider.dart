import 'package:flutter/foundation.dart';
import '../models/saved_recipe_model.dart';
import '../repositories/cookbook_repository.dart';

class CookbookProvider with ChangeNotifier {
  final CookbookRepository _repository;

  CookbookProvider({CookbookRepository? repository})
      : _repository = repository ?? CookbookRepository();

  List<SavedRecipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'Semua';

  List<SavedRecipe> get allRecipes => _recipes;

  List<SavedRecipe> get filteredRecipes {
    if (_selectedFilter == 'Semua') {
      return _recipes;
    }
    return _recipes.where((r) => r.cookStatus == _selectedFilter).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  // Filter Status ('Semua', 'Ingin Dicoba', 'Sudah Dimasak', 'Favorit')
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // READ: Ambil semua data resep tersimpan
  Future<void> fetchSavedRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _repository.getAllSavedRecipes();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE: Tambah resep baru ke cookbook
  Future<bool> addRecipe(SavedRecipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.addRecipe(recipe);
      _recipes.insert(0, created);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE: Perbarui resep yang sudah ada
  Future<bool> updateRecipe(SavedRecipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateRecipe(recipe);
      final index = _recipes.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _recipes[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE: Hapus resep dari cookbook
  Future<bool> deleteRecipe(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.removeRecipe(id);
      _recipes.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper: Cek apakah ID resep sudah disimpan
  bool isMealSaved(String mealId) {
    return _recipes.any((r) => r.mealId == mealId);
  }

  // Helper: Ambil SavedRecipe berdasarkan Meal ID
  SavedRecipe? getSavedRecipeByMealId(String mealId) {
    try {
      return _recipes.firstWhere((r) => r.mealId == mealId);
    } catch (_) {
      return null;
    }
  }
}
