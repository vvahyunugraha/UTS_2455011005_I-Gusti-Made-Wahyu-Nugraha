import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_recipe_model.dart';
import '../services/cookbook_service.dart';
import '../config/supabase_config.dart';

class CookbookRepository {
  final CookbookService _service;

  CookbookRepository({CookbookService? service})
      : _service = service ?? _resolveDefaultService();

  static CookbookService _resolveDefaultService() {
    if (SupabaseConfig.isConfigured) {
      try {
        Supabase.instance;
        return SupabaseCookbookService();
      } catch (_) {
        return LocalMockCookbookService();
      }
    }
    return LocalMockCookbookService();
  }

  Future<List<SavedRecipe>> getAllSavedRecipes() async {
    return await _service.getSavedRecipes();
  }

  Future<SavedRecipe> addRecipe(SavedRecipe recipe) async {
    return await _service.insertRecipe(recipe);
  }

  Future<SavedRecipe> updateRecipe(SavedRecipe recipe) async {
    return await _service.updateRecipe(recipe);
  }

  Future<void> removeRecipe(int id) async {
    return await _service.deleteRecipe(id);
  }
}
