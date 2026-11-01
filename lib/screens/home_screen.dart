import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/cookbook_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_feedback_widgets.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.soup_kitchen_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'CookCraft',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Rekomendasi',
            onPressed: () {
              context.read<MealProvider>().loadInitialData();
            },
          ),
        ],
      ),
      body: Consumer2<MealProvider, CookbookProvider>(
        builder: (context, mealProv, cookProv, child) {
          if (mealProv.isLoading && mealProv.meals.isEmpty) {
            return const CustomLoadingIndicator(message: 'Menyiapkan resep terbaik hari ini...');
          }

          if (mealProv.errorMessage != null && mealProv.meals.isEmpty) {
            return CustomErrorState(
              message: mealProv.errorMessage!,
              onRetry: () => mealProv.loadInitialData(),
            );
          }

          final screenWidth = MediaQuery.of(context).size.width;
          final crossAxisCount = screenWidth >= 900
              ? 4
              : screenWidth >= 600
                  ? 3
                  : 2;

          return RefreshIndicator(
            color: Colors.deepOrange,
            onRefresh: () => mealProv.loadInitialData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Banner
                  Text(
                    'Halo, Mau Masak Apa Hari Ini? 👋',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jelajahi Inspirasi Kuliner',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rekomendasi Hari Ini (Meal of The Day)
                  if (mealProv.randomMeal != null) ...[
                    const Text(
                      '⭐ Rekomendasi Hari Ini',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => RecipeDetailScreen(meal: mealProv.randomMeal!),
                          ),
                        );
                      },
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(mealProv.randomMeal!.thumbnail),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(200),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      mealProv.randomMeal!.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    mealProv.randomMeal!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.public, color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        mealProv.randomMeal!.area,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Lihat Resep →',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Kategori Masakan
                  if (mealProv.categories.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kategori Masakan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${mealProv.categories.length} Kategori',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 95,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: mealProv.categories.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final cat = mealProv.categories[i];
                          final isSelected = mealProv.selectedCategory == cat.name;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              mealProv.selectCategory(cat.name);
                            },
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepOrange.withAlpha(30)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      cat.thumbnail,
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.restaurant,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.deepOrange : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Resep Pilihan / Populer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealProv.selectedCategory == 'All'
                            ? 'Resep Pilihan'
                            : 'Kategori: ${mealProv.selectedCategory}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (mealProv.selectedCategory != 'All')
                        TextButton(
                          onPressed: () => mealProv.selectCategory('All'),
                          child: const Text('Reset', style: TextStyle(color: Colors.deepOrange)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (mealProv.meals.isEmpty)
                    const CustomEmptyState(
                      title: 'Tidak Ada Resep',
                      subtitle: 'Belum ada resep untuk kategori ini.',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                  content: Text('${meal.name} sudah ada di Buku Resep Anda!'),
                                  backgroundColor: Colors.orange.shade800,
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
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
