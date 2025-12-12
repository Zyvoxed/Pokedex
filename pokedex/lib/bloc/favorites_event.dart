part of 'favorites_bloc.dart';

abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class AddFavorite extends FavoritesEvent {
  final Pokemon pokemon;
  AddFavorite(this.pokemon);
}

class RemoveFavorite extends FavoritesEvent {
  final Pokemon pokemon;
  RemoveFavorite(this.pokemon);
}
