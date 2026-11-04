import 'package:flutter/foundation.dart';
import '../services/pokemon_api_service.dart';
import 'pokemon_state.dart';

/// Gestiona el estado de la pantalla de Pokémon (Loading/Success/Error)
/// usando el patrón Provider + ChangeNotifier.
class PokemonProvider extends ChangeNotifier {
  final PokemonApiService _apiService;

  PokemonProvider({PokemonApiService? apiService})
      : _apiService = apiService ?? PokemonApiService();

  PokemonState _state = const PokemonLoading();
  PokemonState get state => _state;

  /// Carga (o recarga, p. ej. desde Pull-to-Refresh) el listado de Pokémon.
  Future<void> loadPokemons() async {
    _state = const PokemonLoading();
    notifyListeners();

    try {
      final response = await _apiService.fetchPokemonList(limit: 30);
      _state = PokemonSuccess(response.results);
    } on PokemonApiException catch (e) {
      _state = PokemonError(e.message);
    } catch (e) {
      _state = PokemonError('Ocurrió un error inesperado: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
