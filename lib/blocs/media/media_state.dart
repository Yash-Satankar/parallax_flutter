import 'package:equatable/equatable.dart';
import 'package:parallax_mobile/data/models.dart';

abstract class MediaState extends Equatable {
  const MediaState();
  @override
  List<Object?> get props => [];
}

class MediaInitial extends MediaState {
  const MediaInitial();
}

class MediaLoading extends MediaState {
  const MediaLoading();
}

class MediaLoaded extends MediaState {
  final List<MediaAsset> assets;
  final List<MediaSearchHit> searchHits;
  final String searchQuery;
  final bool isSearching;

  const MediaLoaded({
    required this.assets,
    this.searchHits = const [],
    this.searchQuery = '',
    this.isSearching = false,
  });

  MediaLoaded copyWith({
    List<MediaAsset>? assets,
    List<MediaSearchHit>? searchHits,
    String? searchQuery,
    bool? isSearching,
  }) {
    return MediaLoaded(
      assets: assets ?? this.assets,
      searchHits: searchHits ?? this.searchHits,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [assets, searchHits, searchQuery, isSearching];
}

class MediaUploading extends MediaState {
  final List<MediaAsset> existingAssets;
  const MediaUploading(this.existingAssets);
  @override
  List<Object?> get props => [existingAssets];
}

class MediaError extends MediaState {
  final String message;
  final List<MediaAsset> existingAssets;
  const MediaError(this.message, {this.existingAssets = const []});
  @override
  List<Object?> get props => [message, existingAssets];
}
