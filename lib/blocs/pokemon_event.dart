import 'package:equatable/equatable.dart';

abstract class PokemonEvent extends Equatable {
  const PokemonEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the list screen is first shown.
class PokemonListRequested extends PokemonEvent {
  const PokemonListRequested();
}

/// Fired by Pull-to-Refresh to re-fetch the data manually.
class PokemonListRefreshed extends PokemonEvent {
  const PokemonListRefreshed();
}
