import 'package:equatable/equatable.dart';
import '../models/pokemon.dart';

abstract class PokemonState extends Equatable {
  const PokemonState();

  @override
  List<Object?> get props => [];
}

/// Initial / in-flight request state.
class PokemonLoading extends PokemonState {
  const PokemonLoading();
}

/// Request succeeded; carries the data to render.
class PokemonSuccess extends PokemonState {
  final List<Pokemon> pokemons;

  const PokemonSuccess(this.pokemons);

  @override
  List<Object?> get props => [pokemons];
}

/// Request failed (network error, timeout, bad status code, parsing error).
class PokemonError extends PokemonState {
  final String message;

  const PokemonError(this.message);

  @override
  List<Object?> get props => [message];
}
