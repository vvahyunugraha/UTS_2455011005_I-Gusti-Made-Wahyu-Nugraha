import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final String message;

  const CustomLoadingIndicator({
    super.key,
    this.message = 'Memuat resep lezat...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Colors.deepOrange,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const CustomEmptyState({
    super.key,
    this.title = 'Belum Ada Data',
    this.subtitle = 'Tidak ditemukan resep yang sesuai.',
    this.icon = Icons.restaurant_menu_rounded,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.deepOrange),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CustomErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 54, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kendala Jaringan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

