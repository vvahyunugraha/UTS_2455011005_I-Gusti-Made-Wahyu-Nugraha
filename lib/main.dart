import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/meal_provider.dart';
import 'providers/cookbook_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase jika konfigurasi sudah diisi oleh pengguna
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabasePublishableKey,
    );
  }

  runApp(const CookCraftApp());
}

class CookCraftApp extends StatelessWidget {
  const CookCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MealProvider()..loadInitialData(),
        ),
        ChangeNotifierProvider(
          create: (_) => CookbookProvider()..fetchSavedRecipes(),
        ),
      ],
      child: MaterialApp(
        title: 'CookCraft',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            primary: Colors.deepOrange,
            secondary: Colors.amber,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF9F9FB),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 1,
            backgroundColor: Color(0xFFF9F9FB),
            foregroundColor: Color(0xFF1E1E1E),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}
