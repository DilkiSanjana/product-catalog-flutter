
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'repositories/product_repository.dart';
import 'services/product_api_service.dart';
import 'screens/product_list_screen.dart';
import 'providers/cart_provider.dart';

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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}
