import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_recipe_model.dart';
import '../providers/cookbook_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/state_feedback_widgets.dart';
import 'edit_recipe_screen.dart';

class MyCookbookScreen extends StatefulWidget {
  const MyCookbookScreen({super.key});

  @override
  State<MyCookbookScreen> createState() => _MyCookbookScreenState();
}

class _MyCookbookScreenState extends State<MyCookbookScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<CookbookProvider>().fetchSavedRecipes();
      }
    });
  }

  void _confirmDelete(BuildContext context, SavedRecipe recipe) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Resep?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${recipe.mealName}" dari Buku Resep Anda? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (recipe.id != null) {
                final success = await context.read<CookbookProvider>().deleteRecipe(recipe.id!);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Resep "${recipe.mealName}" berhasil dihapus.')),
                        ],
                      ),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Semua', 'Ingin Dicoba', 'Sudah Dimasak', 'Favorit'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Resep Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sinkronisasi Data',
            onPressed: () {
              context.read<CookbookProvider>().fetchSavedRecipes();
            },
          ),
        ],
      ),
      body: Consumer<CookbookProvider>(
        builder: (context, cookProv, child) {
          final recipes = cookProv.filteredRecipes;

          return Column(
            children: [
              // Filter Chips
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final filter = filters[i];
                    final isSelected = cookProv.selectedFilter == filter;

                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => cookProv.setFilter(filter),
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

              const Divider(height: 1),

              // Total count info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${recipes.length} resep tersimpan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'Filter: ${cookProv.selectedFilter}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // Recipe List or Empty State
              Expanded(
                child: cookProv.isLoading
                    ? const CustomLoadingIndicator(message: 'Memuat buku resep...')
                    : cookProv.errorMessage != null
                        ? CustomErrorState(
                            message: cookProv.errorMessage!,
                            onRetry: () => cookProv.fetchSavedRecipes(),
                          )
                        : recipes.isEmpty
                            ? CustomEmptyState(
                                title: 'Belum Ada Resep Tersimpan',
                                subtitle: cookProv.selectedFilter == 'Semua'
                                    ? 'Jelajahi resep di Beranda atau Katalog, lalu simpan resep favorit Anda ke sini!'
                                    : 'Tidak ada resep dengan status "${cookProv.selectedFilter}".',
                                icon: Icons.bookmark_border_rounded,
                              )
                            : RefreshIndicator(
                                color: Colors.deepOrange,
                                onRefresh: () => cookProv.fetchSavedRecipes(),
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: recipes.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (ctx, i) {
                                    final recipe = recipes[i];

                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Top Row: Image, Title, and Rating
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    recipe.thumbnailUrl,
                                                    width: 76,
                                                    height: 76,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      width: 76,
                                                      height: 76,
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
                                                      Text(
                                                        recipe.mealName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            recipe.rating.toStringAsFixed(1),
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            '• ${recipe.category}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          StatusBadge(
                                                            label: recipe.difficultyLevel,
                                                            isSmall: true,
                                                          ),
                                                          const SizedBox(width: 6),
                                                          StatusBadge(
                                                            label: recipe.cookStatus,
                                                            isSmall: true,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Personal Tips Note
                                            if (recipe.personalTips.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey.shade200),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        recipe.personalTips,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade800,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 12),
                                            const Divider(height: 1),
                                            const SizedBox(height: 6),

                                            // Action Buttons: Edit and Delete
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (ctx) => EditRecipeScreen(savedRecipe: recipe),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.teal),
                                                  label: const Text('Edit Catatan', style: TextStyle(color: Colors.teal)),
                                                ),
                                                const SizedBox(width: 8),
                                                TextButton.icon(
                                                  onPressed: () => _confirmDelete(context, recipe),
                                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          ],
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
