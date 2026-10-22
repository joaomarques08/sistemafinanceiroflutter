import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';

class CategoriaRepository {

  static const String _baseUrl = "https://pxmbmmxijhjjevephndy.supabase.co/rest/v1/categorias";
  static const String _publishableKey = "sb_publishable_6amsgJuxkTL907qTkMdZKg_PzT5z0X0";

  final String accessToken;

  CategoriaRepository({required this.accessToken});

  Map<String, String> get _headers => {
    'apikey': _publishableKey,
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  };

  Future<List<Categoria>> buscarCategorias() async {
    final response = await http.get(
      Uri.parse('$_baseUrl?order=nome.asc'),
      headers: _headers
    );

    if (response.statusCode == 200) {
      final List<dynamic> listJson = jsonDecode(response.body);
      return listJson.map((item) => Categoria.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao buscar categorias via REST: ${response.body}');
    }
  }

  Future<Categoria> criarCategoria(Categoria categoria) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(categoria.toJson())
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final List<dynamic> responseList = jsonDecode(response.body);
      return Categoria.fromJson(responseList.first);
    } else {
      throw Exception('Falha ao salvar categoria via REST: ${response.body}');
    }
  }

}
