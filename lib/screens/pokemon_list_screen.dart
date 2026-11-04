import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/pokemon_bloc.dart';
import '../blocs/pokemon_event.dart';
import '../blocs/pokemon_state.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_card.dart';

class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
      ),
      body: BlocBuilder<PokemonBloc, PokemonState>(
        builder: (context, state) {
          if (state is PokemonLoading) {
            return const _LoadingView();
          } else if (state is PokemonSuccess) {
            return _SuccessView(pokemons: state.pokemons);
          } else if (state is PokemonError) {
            return _ErrorView(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando Pokémon...'),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final List<Pokemon> pokemons;

  const _SuccessView({required this.pokemons});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PokemonBloc>().add(const PokemonListRefreshed());
        await context.read<PokemonBloc>().stream.firstWhere((s) => s is! PokemonLoading);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: pokemons.length,
        itemBuilder: (context, index) => PokemonCard(pokemon: pokemons[index]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PokemonBloc>().add(const PokemonListRefreshed());
        await context.read<PokemonBloc>().stream.firstWhere((s) => s is! PokemonLoading);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: () => context.read<PokemonBloc>().add(const PokemonListRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}
