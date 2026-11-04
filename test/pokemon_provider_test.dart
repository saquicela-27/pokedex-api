import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/providers/pokemon_provider.dart';
import 'package:pokedex_app/providers/pokemon_state.dart';
import 'package:pokedex_app/services/pokemon_api_service.dart';

class _FakeSuccessService extends PokemonApiService {
  @override
  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    return PokemonListResponse(
      count: 2,
      results: const [
        Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'https://example.com/1.png'),
        Pokemon(id: 4, name: 'charmander', imageUrl: 'https://example.com/4.png'),
      ],
    );
  }
}

class _FakeNetworkErrorService extends PokemonApiService {
  @override
  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    throw PokemonApiException('Sin conexión a internet. Verifica tu red e intenta de nuevo.');
  }
}

class _FakeServerErrorService extends PokemonApiService {
  @override
  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    throw PokemonApiException('Error del servidor (código 500) al consultar PokeAPI.');
  }
}

void main() {
  group('PokemonProvider', () {
    test('estado inicial es PokemonLoading', () {
      final provider = PokemonProvider(apiService: _FakeSuccessService());
      expect(provider.state, isA<PokemonLoading>());
    });

    test('termina en PokemonSuccess cuando la API responde correctamente', () async {
      final provider = PokemonProvider(apiService: _FakeSuccessService());

      await provider.loadPokemons();

      expect(provider.state, isA<PokemonSuccess>());
      final success = provider.state as PokemonSuccess;
      expect(success.pokemons.length, 2);
      expect(success.pokemons.first.name, 'bulbasaur');
    });

    test('termina en PokemonError con mensaje de red cuando no hay conexión', () async {
      final provider = PokemonProvider(apiService: _FakeNetworkErrorService());

      await provider.loadPokemons();

      expect(provider.state, isA<PokemonError>());
      expect((provider.state as PokemonError).message, contains('conexión'));
    });

    test('termina en PokemonError cuando el servidor responde con error', () async {
      final provider = PokemonProvider(apiService: _FakeServerErrorService());

      await provider.loadPokemons();

      expect(provider.state, isA<PokemonError>());
      expect((provider.state as PokemonError).message, contains('500'));
    });

    test('notifica a los listeners al cargar', () async {
      final provider = PokemonProvider(apiService: _FakeSuccessService());
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.loadPokemons();

      // Una notificación al entrar en Loading y otra al llegar a Success.
      expect(notifications, 2);
    });
  });

  group('Pokemon.fromJson', () {
    test('extrae el id numérico desde la URL de PokeAPI', () {
      final pokemon = Pokemon.fromJson({
        'name': 'pikachu',
        'url': 'https://pokeapi.co/api/v2/pokemon/25/',
      });

      expect(pokemon.id, 25);
      expect(pokemon.name, 'pikachu');
      expect(pokemon.imageUrl, contains('25.png'));
    });
  });
}
