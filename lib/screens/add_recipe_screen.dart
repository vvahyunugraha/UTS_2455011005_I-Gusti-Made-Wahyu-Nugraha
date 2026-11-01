import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_model.dart';
import '../models/saved_recipe_model.dart';
import '../providers/cookbook_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  final Meal meal;

  const AddRecipeScreen({super.key, required this.meal});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  String _difficultyLevel = 'Sedang';
  String _cookStatus = 'Ingin Dicoba';
  double _rating = 5.0;
  final TextEditingController _tipsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tipsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final newRecipe = SavedRecipe(
      mealId: widget.meal.id,
      mealName: widget.meal.name,
      category: widget.meal.category,
      thumbnailUrl: widget.meal.thumbnail,
      difficultyLevel: _difficultyLevel,
      cookStatus: _cookStatus,
      rating: _rating,
      personalTips: _tipsController.text.trim(),
    );

    final success = await context.read<CookbookProvider>().addRecipe(newRecipe);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('${widget.meal.name} berhasil disimpan ke Buku Resep!')),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<CookbookProvider>().errorMessage ?? 'Gagal menyimpan resep';
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
        title: const Text('Simpan ke Buku Resep', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card Info
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
                          widget.meal.thumbnail,
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
                              widget.meal.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kategori: ${widget.meal.category}',
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

              // Field 1: Tingkat Kesulitan
              const Text(
                'Tingkat Kesulitan Memasak *',
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

              // Field 2: Status Memasak
              const Text(
                'Status Resep *',
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

              // Field 3: Rating Ekspektasi / Hasil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rating Resep (1 - 5) *',
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

              // Field 4: Catatan & Tips Rahasia
              const Text(
                'Catatan & Tips Pribadi *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tipsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Contoh: Gunakan api kecil saat menumis bawang, tambahkan sedikit kaldu jamur...',
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

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Resep',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
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
