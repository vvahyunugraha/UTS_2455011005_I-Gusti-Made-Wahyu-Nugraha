import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_recipe_model.dart';

abstract class CookbookService {
  Future<List<SavedRecipe>> getSavedRecipes();
  Future<SavedRecipe> insertRecipe(SavedRecipe recipe);
  Future<SavedRecipe> updateRecipe(SavedRecipe recipe);
  Future<void> deleteRecipe(int id);
}

/// Implementasi Supabase PostgreSQL Database untuk UTS
class SupabaseCookbookService implements CookbookService {
  SupabaseClient get _client => Supabase.instance.client;
  static const String _tableName = 'my_cookbook';

  @override
  Future<List<SavedRecipe>> getSavedRecipes() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((map) => SavedRecipe.fromMap(map)).toList();
  }

  @override
  Future<SavedRecipe> insertRecipe(SavedRecipe recipe) async {
    final map = recipe.toMap();
    map.remove('id'); // ID dihasilkan otomatis oleh database PostgreSQL

    final response = await _client
        .from(_tableName)
        .insert(map)
        .select()
        .single();

    return SavedRecipe.fromMap(response);
  }

  @override
  Future<SavedRecipe> updateRecipe(SavedRecipe recipe) async {
    if (recipe.id == null) {
      throw Exception('ID resep diperlukan untuk memperbarui data');
    }

    final map = recipe.toMap();
    final response = await _client
        .from(_tableName)
        .update(map)
        .eq('id', recipe.id!)
        .select()
        .single();

    return SavedRecipe.fromMap(response);
  }

  @override
  Future<void> deleteRecipe(int id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

/// Fallback lokal jika kredensial Supabase belum diisi oleh pengguna
class LocalMockCookbookService implements CookbookService {
  final List<SavedRecipe> _items = [
    SavedRecipe(
      id: 1,
      mealId: '52772',
      mealName: 'Teriyaki Chicken Casserole',
      category: 'Chicken',
      thumbnailUrl: 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      difficultyLevel: 'Mudah',
      cookStatus: 'Favorit',
      rating: 4.9,
      personalTips: 'Tambahkan wijen sangrai di atasnya dan sajikan hangat bersama nasi putih pulen.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SavedRecipe(
      id: 2,
      mealId: '52977',
      mealName: 'Corba (Turkish Lentil Soup)',
      category: 'Side',
      thumbnailUrl: 'https://www.themealdb.com/images/media/meals/58oia91598732431.jpg',
      difficultyLevel: 'Sedang',
      cookStatus: 'Ingin Dicoba',
      rating: 4.5,
      personalTips: 'Perbanyak perasan lemon dan bubuk cabai merah kering saat penyajian.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  int _nextId = 3;

  @override
  Future<List<SavedRecipe>> getSavedRecipes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_items);
  }

  @override
  Future<SavedRecipe> insertRecipe(SavedRecipe recipe) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newRecipe = recipe.copyWith(id: _nextId++);
    _items.insert(0, newRecipe);
    return newRecipe;
  }

  @override
  Future<SavedRecipe> updateRecipe(SavedRecipe recipe) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((e) => e.id == recipe.id);
    if (index != -1) {
      _items[index] = recipe;
      return recipe;
    }
    throw Exception('Resep tidak ditemukan untuk diperbarui');
  }

  @override
  Future<void> deleteRecipe(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((e) => e.id == id);
  }
}
