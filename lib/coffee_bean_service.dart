import 'dart:convert';
import 'package:http/http.dart' as http;

class CoffeeBeanService {
  final String baseUrl = 'http://localhost:8090'; // Your PocketBase URL

  // Fetch coffee beans data (accessible by both admin and subscriber)
  Future<List<Map<String, dynamic>>> fetchCoffeeBeans() async {
    final response = await http.get(Uri.parse('$baseUrl/api/collections/coffee_beans/records'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['items'];
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load coffee beans');
    }
  }

  // Add new coffee bean (only accessible by admin)
  Future<void> addCoffeeBean(Map<String, String> newBean) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/collections/coffee_beans/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newBean),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add coffee bean');
    }
  }

  // Delete a coffee bean (only accessible by admin)
  Future<void> deleteCoffeeBean(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/collections/coffee_beans/records/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete coffee bean');
    }
  }
}
