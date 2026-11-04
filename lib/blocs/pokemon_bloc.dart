import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/pokemon_api_service.dart';
import 'pokemon_event.dart';
import 'pokemon_state.dart';

class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final PokemonApiService _apiService;

  PokemonBloc({PokemonApiService? apiService})
      : _apiService = apiService ?? PokemonApiService(),
        super(const PokemonLoading()) {
    on<PokemonListRequested>(_onListRequested);
    on<PokemonListRefreshed>(_onListRequested);
  }

  Future<void> _onListRequested(
    PokemonEvent event,
    Emitter<PokemonState> emit,
  ) async {
    emit(const PokemonLoading());
    try {
      final response = await _apiService.fetchPokemonList(limit: 30);
      emit(PokemonSuccess(response.results));
    } on SocketException {
      emit(const PokemonError(
        'Sin conexión a internet. Verifica tu red e intenta de nuevo.',
      ));
    } on PokemonApiException catch (e) {
      emit(PokemonError(e.message));
    } catch (e) {
      emit(PokemonError('Ocurrió un error inesperado: $e'));
    }
  }

  @override
  Future<void> close() {
    _apiService.dispose();
    return super.close();
  }
}
