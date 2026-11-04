import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/blocs/pokemon_bloc.dart';
import 'package:pokedex_app/blocs/pokemon_event.dart';
import 'package:pokedex_app/blocs/pokemon_state.dart';
import 'package:pokedex_app/models/pokemon.dart';
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
    throw const SocketException('No network');
  }
}

class _FakeServerErrorService extends PokemonApiService {
  @override
  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    throw PokemonApiException('Error del servidor (código 500) al consultar PokeAPI.');
  }
}

void main() {
  group('PokemonBloc', () {
    test('estado inicial es PokemonLoading', () {
      final bloc = PokemonBloc(apiService: _FakeSuccessService());
      expect(bloc.state, isA<PokemonLoading>());
      bloc.close();
    });

    test('emite [Loading, Success] cuando la API responde correctamente', () async {
      final bloc = PokemonBloc(apiService: _FakeSuccessService());
      final states = <PokemonState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PokemonListRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.first, isA<PokemonLoading>());
      expect(states.last, isA<PokemonSuccess>());
      expect((states.last as PokemonSuccess).pokemons.length, 2);
      expect((states.last as PokemonSuccess).pokemons.first.name, 'bulbasaur');

      await sub.cancel();
      await bloc.close();
    });

    test('emite PokemonError con mensaje de red cuando no hay conexión', () async {
      final bloc = PokemonBloc(apiService: _FakeNetworkErrorService());
      final states = <PokemonState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PokemonListRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.last, isA<PokemonError>());
      expect((states.last as PokemonError).message, contains('conexión'));

      await sub.cancel();
      await bloc.close();
    });

    test('emite PokemonError cuando el servidor responde con error', () async {
      final bloc = PokemonBloc(apiService: _FakeServerErrorService());
      final states = <PokemonState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PokemonListRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.last, isA<PokemonError>());
      expect((states.last as PokemonError).message, contains('500'));

      await sub.cancel();
      await bloc.close();
    });

    test('PokemonListRefreshed vuelve a pasar por Loading antes de Success', () async {
      final bloc = PokemonBloc(apiService: _FakeSuccessService());
      final states = <PokemonState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PokemonListRequested());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const PokemonListRefreshed());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 4);
      expect(states[2], isA<PokemonLoading>());
      expect(states[3], isA<PokemonSuccess>());

      await sub.cancel();
      await bloc.close();
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
