import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_recipe_model.dart';
import '../providers/cookbook_provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final SavedRecipe savedRecipe;

  const EditRecipeScreen({super.key, required this.savedRecipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _difficultyLevel;
  late String _cookStatus;
  late double _rating;
  late final TextEditingController _tipsController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _difficultyLevel = widget.savedRecipe.difficultyLevel;
    _cookStatus = widget.savedRecipe.cookStatus;
    _rating = widget.savedRecipe.rating;
    _tipsController = TextEditingController(text: widget.savedRecipe.personalTips);
  }

  @override
  void dispose() {
    _tipsController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final updated = widget.savedRecipe.copyWith(
      difficultyLevel: _difficultyLevel,
      cookStatus: _cookStatus,
      rating: _rating,
      personalTips: _tipsController.text.trim(),
    );

    final success = await context.read<CookbookProvider>().updateRecipe(updated);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Catatan resep "${widget.savedRecipe.mealName}" berhasil diperbarui!')),
            ],
          ),
          backgroundColor: Colors.teal.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<CookbookProvider>().errorMessage ?? 'Gagal memperbarui resep';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Catatan Resep', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Header Info
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.savedRecipe.thumbnailUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 70,
                            height: 70,
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
                              widget.savedRecipe.mealName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kategori: ${widget.savedRecipe.category}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Difficulty Level
              const Text(
                'Tingkat Kesulitan Memasak',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Mudah', 'Sedang', 'Sulit'].map((level) {
                  final isSelected = _difficultyLevel == level;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Center(child: Text(level)),
                        selected: isSelected,
                        selectedColor: Colors.deepOrange.withAlpha(40),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.deepOrange : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setState(() => _difficultyLevel = level);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Cook Status
              const Text(
                'Status Memasak',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _cookStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.bookmark_added_rounded, color: Colors.deepOrange),
                ),
                items: const [
                  DropdownMenuItem(value: 'Ingin Dicoba', child: Text('📌 Ingin Dicoba')),
                  DropdownMenuItem(value: 'Sudah Dimasak', child: Text('🍳 Sudah Pernah Dimasak')),
                  DropdownMenuItem(value: 'Favorit', child: Text('❤️ Masakan Favorit')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _cookStatus = val);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rating Kepuasan (1 - 5)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: Colors.deepOrange,
                inactiveColor: Colors.deepOrange.withAlpha(50),
                label: _rating.toStringAsFixed(1),
                onChanged: (val) {
                  setState(() => _rating = val);
                },
              ),
              const SizedBox(height: 16),

              // Personal Tips
              const Text(
                'Catatan & Tips Pribadi *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tipsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Perbarui catatan Anda...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Catatan pribadi wajib diisi minimal 5 karakter';
                  }
                  if (value.trim().length < 5) {
                    return 'Catatan terlalu singkat, minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitUpdate,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _isSubmitting ? 'Memperbarui...' : 'Simpan Perubahan',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
