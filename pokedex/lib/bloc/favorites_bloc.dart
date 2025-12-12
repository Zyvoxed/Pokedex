import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import 'dart:convert';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesState(favorites: [])) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);

    add(LoadFavorites()); // load saved favorites on init
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    final favorites = favList
        .map((e) => Pokemon.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    emit(FavoritesState(favorites: favorites));
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final updated = List<Pokemon>.from(state.favorites)..add(event.pokemon);
    emit(FavoritesState(favorites: updated));
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'favorites',
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final updated = List<Pokemon>.from(state.favorites)
      ..removeWhere((p) => p.name == event.pokemon.name);
    emit(FavoritesState(favorites: updated));
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'favorites',
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
