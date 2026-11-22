
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/providers/favorite_provider.dart';
import 'package:product_catalog/widgets/product_card.dart';
import 'package:product_catalog/screens/product_detail_screen.dart';

/// Wraps [child] with the providers required by [ProductCard].
Widget buildTestableWidget(Widget child) {
  SharedPreferences.setMockInitialValues({});

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => FavoriteProvider(),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

const Product testProduct = Product(
  id: 1,
  title: 'Test iPhone',
  description: 'A test smartphone product',
  price: 799.99,
  rating: 4.5,
  stock: 5,
  thumbnail: 'https://example.com/image.jpg',
  category: 'smartphones',
  brand: 'Apple',
  images: [],
);

void main() {
  group('ProductCard Widget Tests', () {
    testWidgets('renders product title and price', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: testProduct),
          ),
        ),
      );

      // Title appears on the card.
      expect(find.text('Test iPhone'), findsOneWidget);

      // Price is formatted and displayed.
      expect(find.text('\$799.99'), findsOneWidget);
    });

    testWidgets('renders star rating', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: testProduct),
          ),
        ),
      );

      // Rating value is shown.
      expect(find.text('4.5'), findsOneWidget);

      // Star icon is present.
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('tapping card navigates to ProductDetailScreen',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: testProduct),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      // ProductDetailScreen should now be on screen.
      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });

    testWidgets('favorite icon toggles when tapped', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: testProduct),
          ),
        ),
      );

      // Initially the product is not a favorite.
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap the favorite button.
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      // After tap, should show filled heart.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });
}
