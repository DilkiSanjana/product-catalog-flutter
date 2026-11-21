
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client client;

  ProductApiService({http.Client? client})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/products?limit=$limit&skip=$skip',
    );

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
        'Failed to load products. Status: ${response.statusCode}',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Network connection failed. Please try again.');
    } on FormatException {
      throw Exception('Invalid data received from the server.');
    }
  }

  Future<Map<String, dynamic>> searchProducts(
    String query,
  ) async {
    final uri = Uri.parse('$_baseUrl/products/search').replace(
      queryParameters: {'q': query},
    );

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
        'Search failed. Status: ${response.statusCode}',
      );
    } on TimeoutException {
      throw Exception('Search request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Network connection failed. Please try again.');
    } on FormatException {
      throw Exception('Invalid search response.');
    }
  }

  Future<Map<String, dynamic>> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');

    try {
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }

        throw const FormatException('Invalid product response');
      }

      throw Exception(
        'Failed to load product. Status: ${response.statusCode}',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Network connection failed. Please try again.');
    } on FormatException {
      throw Exception('Invalid product response.');
    }
  }

  void dispose() {
    client.close();
  }
}
