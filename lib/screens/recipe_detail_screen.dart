import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_model.dart';
import '../providers/meal_provider.dart';
import '../providers/cookbook_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/state_feedback_widgets.dart';
import 'add_recipe_screen.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Meal meal;

  const RecipeDetailScreen({super.key, required this.meal});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load full details jika bahan-bahannya belum termuat (misal dari filter API)
    if (widget.meal.ingredients.isEmpty) {
      Future.microtask(() {
        if (mounted) {
          context.read<MealProvider>().loadMealDetail(widget.meal.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MealProvider, CookbookProvider>(
      builder: (context, mealProv, cookProv, child) {
        final currentMeal = (widget.meal.ingredients.isEmpty &&
                mealProv.selectedMeal != null &&
                mealProv.selectedMeal!.id == widget.meal.id)
            ? mealProv.selectedMeal!
            : widget.meal;

        final isSaved = cookProv.isMealSaved(currentMeal.id);
        final savedItem = isSaved ? cookProv.getSavedRecipeByMealId(currentMeal.id) : null;

        return Scaffold(
          body: mealProv.isLoadingDetail
              ? const CustomLoadingIndicator(message: 'Memuat bahan dan langkah resep...')
              : CustomScrollView(
                  slivers: [
                    // Sliver App Bar with Image & Overlay
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      leading: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: isSaved ? Colors.deepOrangeAccent : Colors.white,
                            ),
                            onPressed: () {
                              if (isSaved && savedItem != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => EditRecipeScreen(savedRecipe: savedItem),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => AddRecipeScreen(meal: currentMeal),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              currentMeal.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.restaurant, size: 60),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withAlpha(90),
                                    Colors.transparent,
                                    Colors.black.withAlpha(150),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recipe Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Category Row
                            Row(
                              children: [
                                StatusBadge(label: currentMeal.category),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: currentMeal.area.isNotEmpty ? currentMeal.area : 'Internasional',
                                  icon: Icons.public,
                                  color: Colors.teal,
                                ),
                                if (isSaved && savedItem != null) ...[
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label: savedItem.cookStatus,
                                    color: Colors.purple,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentMeal.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // If tags exist
                            if (currentMeal.tags.isNotEmpty) ...[
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: currentMeal.tags.map((tag) {
                                  return Chip(
                                    label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.grey.shade100,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Saved Personal Notes (if already saved)
                            if (isSaved && savedItem != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.amber.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Catatan Resep Pribadi Anda',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '★ ${savedItem.rating.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      savedItem.personalTips.isNotEmpty
                                          ? savedItem.personalTips
                                          : 'Tidak ada catatan tambahan.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade800,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            const Divider(),
                            const SizedBox(height: 12),

                            // Section: Ingredients
                            Row(
                              children: [
                                const Icon(Icons.shopping_basket_rounded, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                const Text(
                                  'Bahan-Bahan',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  '${currentMeal.ingredients.length} Bahan',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (currentMeal.ingredients.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Bahan-bahan sedang dimuat atau tidak tersedia secara terpisah.',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentMeal.ingredients.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final item = currentMeal.ingredients[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.deepOrange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.ingredient,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.measure,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 12),

                            // Section: Instructions
                            const Row(
                              children: [
                                Icon(Icons.format_list_numbered_rounded, color: Colors.deepOrange),
                                SizedBox(width: 8),
                                Text(
                                  'Langkah-Langkah Memasak',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                currentMeal.instructions.isNotEmpty
                                    ? currentMeal.instructions
                                    : 'Instruksi memasak belum tersedia untuk menu ini.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: isSaved && savedItem != null
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => EditRecipeScreen(savedRecipe: savedItem),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Edit Catatan Resep Saya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AddRecipeScreen(meal: currentMeal),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_add_rounded),
                      label: const Text('Simpan ke Buku Resep'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
