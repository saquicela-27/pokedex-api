import '../models/pokemon.dart';

/// Estados posibles de la pantalla de listado de Pokémon.
sealed class PokemonState {
  const PokemonState();
}

/// Petición en curso.
class PokemonLoading extends PokemonState {
  const PokemonLoading();
}

/// Petición exitosa; trae los datos a renderizar.
class PokemonSuccess extends PokemonState {
  final List<Pokemon> pokemons;
  const PokemonSuccess(this.pokemons);
}

/// Petición fallida (red, timeout, servidor, parseo).
class PokemonError extends PokemonState {
  final String message;
  const PokemonError(this.message);
}
