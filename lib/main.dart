
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/theme_provider.dart';

import 'repositories/product_repository.dart';
import 'services/product_api_service.dart';

import 'screens/product_list_screen.dart';

void main() {
  final apiService = ProductApiService();

  final repository = ProductRepository(
    apiService: apiService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            repository: repository,
          )..loadInitialProducts(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider()..loadCart(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider()..loadFavorites(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Product Catalog',
          debugShowCheckedModeBanner: false,

          themeMode: themeProvider.themeMode,

          // Light theme
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          // Dark theme
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          home: const ProductListScreen(),
        );
      },
    );
  }
}
