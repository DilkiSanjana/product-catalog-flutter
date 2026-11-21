
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client client;

  ProductApiService({http.Client? client})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }

        throw const FormatException('Invalid API response');
      }

      throw Exception(
        'Request failed. Status: ${response.statusCode}',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Network connection failed. Please try again.');
    } on FormatException {
      throw Exception('Invalid data received from the server.');
    }
  }

  Future<Map<String, dynamic>> fetchProducts({
    int limit = 10,
    int skip = 0,
  }) {
    final uri = Uri.parse(
      '$_baseUrl/products?limit=$limit&skip=$skip',
    );

    return _get(uri);
  }

  Future<Map<String, dynamic>> fetchProductsByCategory({
    required String category,
    int limit = 10,
    int skip = 0,
  }) {
    final uri = Uri.parse(
      '$_baseUrl/products/category/${Uri.encodeComponent(category)}',
    ).replace(
      queryParameters: {
        'limit': '$limit',
        'skip': '$skip',
      },
    );

    return _get(uri);
  }

  Future<List<String>> fetchCategories() async {
      final uri = Uri.parse('$_baseUrl/products/category-list');

  try {
    final response = await client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((item) => item.toString()).toList();
      }

      throw const FormatException('Invalid category response');
    }

    throw Exception(
      'Failed to load categories. Status: ${response.statusCode}',
    );
  } on TimeoutException {
    throw Exception('Request timed out. Please try again.');
  } on http.ClientException {
    throw Exception('Network connection failed. Please try again.');
  } on FormatException {
    throw Exception('Invalid category response.');
  }
  }

  Future<Map<String, dynamic>> searchProducts(
    String query,
  ) async {
    final uri = Uri.parse('$_baseUrl/products/search').replace(
      queryParameters: {'q': query},
    );

    return _get(uri);
  }

  Future<Map<String, dynamic>> fetchProductById(int id) {
    final uri = Uri.parse('$_baseUrl/products/$id');

    return _get(uri);
  }

  void dispose() {
    client.close();
  }
}
