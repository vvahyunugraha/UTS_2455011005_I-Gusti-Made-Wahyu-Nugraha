import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/cookbook_provider.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/recipe_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/state_feedback_widgets.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class RecipeCatalogScreen extends StatefulWidget {
  const RecipeCatalogScreen({super.key});

  @override
  State<RecipeCatalogScreen> createState() => _RecipeCatalogScreenState();
}

class _RecipeCatalogScreenState extends State<RecipeCatalogScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 900
        ? 4
        : screenWidth >= 600
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Resep', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: _isGridView ? 'Ubah ke List View' : 'Ubah ke Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Consumer2<MealProvider, CookbookProvider>(
        builder: (context, mealProv, cookProv, child) {
          return Column(
            children: [
              // Search Bar & Filter Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: CustomSearchBar(
                  initialValue: mealProv.searchQuery,
                  hintText: 'Cari resep (misal: chicken, pasta, soup)...',
                  onSubmitted: (query) {
                    mealProv.search(query);
                  },
                  onClear: () {
                    mealProv.search('');
                  },
                ),
              ),

              // Horizontal Category Filter Pills
              if (mealProv.categories.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    itemCount: mealProv.categories.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final isAll = i == 0;
                      final catName = isAll ? 'All' : mealProv.categories[i - 1].name;
                      final isSelected = mealProv.selectedCategory == catName;

                      return FilterChip(
                        label: Text(isAll ? 'Semua Kategori' : catName),
                        selected: isSelected,
                        onSelected: (_) {
                          mealProv.selectCategory(catName);
                        },
                        selectedColor: Colors.deepOrange.withAlpha(40),
                        checkmarkColor: Colors.deepOrange,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.deepOrange : null,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const Divider(height: 16),

              // Result Info Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menampilkan ${mealProv.meals.length} resep',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Mode: ${_isGridView ? "Grid" : "List"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: mealProv.isLoading
                    ? const CustomLoadingIndicator(message: 'Mencari resep dari API...')
                    : mealProv.errorMessage != null
                        ? CustomErrorState(
                            message: mealProv.errorMessage!,
                            onRetry: () => mealProv.search(mealProv.searchQuery),
                          )
                        : mealProv.meals.isEmpty
                            ? CustomEmptyState(
                                title: 'Resep Tidak Ditemukan',
                                subtitle: 'Coba gunakan kata kunci lain seperti "pasta", "cake", atau "salad".',
                                buttonText: 'Reset Pencarian',
                                onButtonPressed: () => mealProv.search(''),
                              )
                            : RefreshIndicator(
                                color: Colors.deepOrange,
                                onRefresh: () => mealProv.search(mealProv.searchQuery),
                                child: _isGridView
                                    ? GridView.builder(
                                        padding: const EdgeInsets.all(16),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: 0.78,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount: mealProv.meals.length,
                                        itemBuilder: (ctx, i) {
                                          final meal = mealProv.meals[i];
                                          final isSaved = cookProv.isMealSaved(meal.id);
                                          return RecipeCard(
                                            meal: meal,
                                            isSaved: isSaved,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) => RecipeDetailScreen(meal: meal),
                                                ),
                                              );
                                            },
                                            onBookmarkTap: () {
                                              if (isSaved) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${meal.name} sudah tersimpan!'),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) => AddRecipeScreen(meal: meal),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        },
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: mealProv.meals.length,
                                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                                        itemBuilder: (ctx, i) {
                                          final meal = mealProv.meals[i];
                                          final isSaved = cookProv.isMealSaved(meal.id);

                                          return Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            elevation: 2,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(16),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (ctx) => RecipeDetailScreen(meal: meal),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.network(
                                                        meal.thumbnail,
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => Container(
                                                          width: 80,
                                                          height: 80,
                                                          color: Colors.grey.shade200,
                                                          child: const Icon(Icons.fastfood),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          StatusBadge(label: meal.category, isSmall: true),
                                                          const SizedBox(height: 6),
                                                          Text(
                                                            meal.name,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.public, size: 14, color: Colors.grey),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                meal.area.isNotEmpty ? meal.area : 'Internasional',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.grey.shade600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                                                        color: isSaved ? Colors.deepOrange : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        if (isSaved) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('${meal.name} sudah ada di buku resep!'),
                                                              behavior: SnackBarBehavior.floating,
                                                            ),
                                                          );
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (ctx) => AddRecipeScreen(meal: meal),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}
