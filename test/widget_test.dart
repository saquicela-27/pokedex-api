import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/blocs/pokemon_bloc.dart';
import 'package:pokedex_app/blocs/pokemon_event.dart';
import 'package:pokedex_app/models/pokemon.dart';
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
    throw const SocketException('No network');
  }
}

Widget _wrap(PokemonBloc bloc) {
  return MaterialApp(
    home: BlocProvider.value(value: bloc, child: const PokemonListScreen()),
  );
}

void main() {
  testWidgets('muestra el indicador de carga mientras la petición está en curso',
      (tester) async {
    final bloc = PokemonBloc(apiService: _FakeSuccessService())
      ..add(const PokemonListRequested());

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando Pokémon...'), findsOneWidget);

    await tester.pumpAndSettle();
    await bloc.close();
  });

  testWidgets('muestra la grilla de tarjetas cuando la API responde con éxito',
      (tester) async {
    final bloc = PokemonBloc(apiService: _FakeSuccessService())
      ..add(const PokemonListRequested());

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.textContaining('Bulbasaur'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await bloc.close();
  });

  testWidgets('muestra pantalla de error y botón de reintentar sin conexión',
      (tester) async {
    final bloc = PokemonBloc(apiService: _FakeNetworkErrorService())
      ..add(const PokemonListRequested());

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.textContaining('conexión'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Reintentar'), findsOneWidget);

    await bloc.close();
  });
}
