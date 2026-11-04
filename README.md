# Pokédex API — Actividad Integradora 3

Aplicación móvil Flutter que consume la [PokeAPI](https://pokeapi.co/) (API
REST pública, gratuita y sin autenticación) para mostrar un listado de
Pokémon con sus datos actualizados en tiempo real.

## API pública utilizada

- **Nombre:** PokeAPI v2
- **Endpoint consumido:** `GET https://pokeapi.co/api/v2/pokemon?limit=30&offset=0`
- **Documentación:** https://pokeapi.co/docs/v2#pokemon
- **Por qué esta API:** es completamente gratuita, no requiere token ni
  registro, tiene una estructura JSON simple y estable, y permite construir
  una interfaz visual atractiva (imágenes oficiales de cada Pokémon).

## Arquitectura

- **Capa de servicios** (`lib/services/pokemon_api_service.dart`): realiza la
  petición HTTP con el paquete `http` y lanza excepciones tipadas en caso de
  error de red o de servidor.
- **Modelo** (`lib/models/pokemon.dart`): mapea el JSON de la API a un objeto
  Dart (`fromJson` / `toJson`).
- **Gestión de estado** (`lib/blocs/`): implementado con `flutter_bloc`
  (`PokemonBloc`), con tres estados: `PokemonLoading`, `PokemonSuccess` y
  `PokemonError`.
- **UI** (`lib/screens/`, `lib/widgets/`): pantalla con `GridView` de
  tarjetas, `RefreshIndicator` para Pull-to-Refresh, y vistas dedicadas para
  cada estado (carga, éxito, error con botón de reintentar).

## Cómo ejecutar la aplicación

Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x instalado.

```bash
flutter pub get
flutter run -d chrome   # o -d windows / -d <dispositivo conectado>
```

## Cómo ejecutar las pruebas

```bash
flutter test
```

Las pruebas (`test/pokemon_bloc_test.dart`, `test/widget_test.dart`) usan
implementaciones falsas del servicio de API para verificar los tres estados
(carga, éxito y error de red) sin depender de la red real.
