import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/providers/pokemon_provider.dart';
import 'package:pokedex_app/screens/pokemon_list_screen.dart';
import 'package:pokedex_app/services/pokemon_api_service.dart';

class _FakeSuccessService extends PokemonApiService {
  @override
  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return PokemonListResponse(
      count: 1,
      results: const [Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'https://example.com/1.png')],
    );
  }
}

class _FakeNetworkErrorService extends PokemonApiService {
  @override
  Future<PokemonListResponse> fetchPokemonList({int limit = 30, int offset = 0}) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw PokemonApiException('Sin conexión a internet. Verifica tu red e intenta de nuevo.');
  }
}

Widget _wrap(PokemonProvider provider) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(value: provider, child: const PokemonListScreen()),
  );
}

void main() {
  testWidgets('muestra el indicador de carga mientras la petición está en curso',
      (tester) async {
    final provider = PokemonProvider(apiService: _FakeSuccessService());
    unawaited(provider.loadPokemons());

    await tester.pumpWidget(_wrap(provider));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando Pokémon...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
  });

  testWidgets('muestra la grilla de tarjetas cuando la API responde con éxito',
      (tester) async {
    final provider = PokemonProvider(apiService: _FakeSuccessService());
    unawaited(provider.loadPokemons());

    await tester.pumpWidget(_wrap(provider));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.textContaining('Bulbasaur'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('muestra pantalla de error y botón de reintentar sin conexión',
      (tester) async {
    final provider = PokemonProvider(apiService: _FakeNetworkErrorService());
    unawaited(provider.loadPokemons());

    await tester.pumpWidget(_wrap(provider));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.textContaining('conexión'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Reintentar'), findsOneWidget);
  });
}
