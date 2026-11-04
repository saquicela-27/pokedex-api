import 'dart:async';
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

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw PokemonApiException(
        'Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo.',
      );
    } on http.ClientException {
      // Lanzado tanto por dart:io (móvil/desktop) como por el cliente fetch
      // en Flutter Web cuando no hay conexión o el host no responde.
      throw PokemonApiException(
        'Sin conexión a internet. Verifica tu red e intenta de nuevo.',
      );
    }

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
