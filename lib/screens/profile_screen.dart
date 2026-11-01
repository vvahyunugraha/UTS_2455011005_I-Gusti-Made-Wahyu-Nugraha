import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cookbook_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengembang', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<CookbookProvider>(
        builder: (context, cookProv, child) {
          final allRecipes = cookProv.allRecipes;
          final favoriteCount = allRecipes.where((r) => r.cookStatus == 'Favorit').length;
          final cookedCount = allRecipes.where((r) => r.cookStatus == 'Sudah Dimasak').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Avatar & Mahasiswa Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepOrange, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withAlpha(50),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Wahyu Nugraha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NIM: 2215101000 | Kelas: TI-5A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Grid
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Tersimpan',
                      value: '${allRecipes.length}',
                      icon: Icons.bookmark_added_rounded,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      title: 'Favorit',
                      value: '$favoriteCount',
                      icon: Icons.favorite_rounded,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      title: 'Dimasak',
                      value: '$cookedCount',
                      icon: Icons.soup_kitchen_rounded,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Info Project UTS
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_turned_in_rounded, color: Colors.deepOrange),
                            SizedBox(width: 8),
                            Text(
                              'Informasi Project UTS',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Mata Kuliah', 'Workshop Pengembangan Aplikasi Mobile'),
                        _buildInfoRow('Tema Project', 'CookCraft - Katalog Resep & Buku Masak'),
                        _buildInfoRow('State Management', 'Provider + ChangeNotifier'),
                        _buildInfoRow('REST API', 'TheMealDB Public API (JSON)'),
                        _buildInfoRow('Database Backend', 'Supabase PostgreSQL (Ready)'),
                        _buildInfoRow('Arsitektur', 'Clean Architecture (UI → Provider → Repo → Service)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Fitur yang Diimplementasi
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Checklist Fitur UTS',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildCheckItem('≥ 6 Functional Screens (Home, Catalog, Detail, Add, Edit, Saved, Profile)'),
                        _buildCheckItem('Katalog Resep Real-Time dari REST API'),
                        _buildCheckItem('Full CRUD Operasi Buku Resep Pribadi'),
                        _buildCheckItem('Responsive Layout (Compact & Wide LayoutBuilder)'),
                        _buildCheckItem('Form Validation & Dialog Konfirmasi Hapus'),
                        _buildCheckItem('Loading, Error, dan Empty State Handling'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

