import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// Thin wrapper around the public PokeAPI REST endpoint.
/// https://pokeapi.co/docs/v2#pokemon
class PokemonApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  final http.Client _client;

  PokemonApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    final uri = Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset');

    final response = await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw PokemonApiException(
        'Error del servidor (código ${response.statusCode}) al consultar PokeAPI.',
      );
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PokemonListResponse.fromJson(jsonBody);
  }

  void dispose() => _client.close();
}

class PokemonApiException implements Exception {
  final String message;
  PokemonApiException(this.message);

  @override
  String toString() => message;
}
