import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parallax_mobile/blocs/media/media_event.dart';
import 'package:parallax_mobile/blocs/media/media_state.dart';
import 'package:parallax_mobile/data/parallax_api.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final ParallaxApi api;
  final String projectId;

  MediaBloc({required this.api, required this.projectId})
      : super(const MediaInitial()) {
    on<MediaLoadRequested>(_onLoad);
    on<MediaSearchRequested>(_onSearch);
    on<MediaSearchCleared>(_onSearchCleared);
    on<MediaUploadRequested>(_onUpload);
    on<MediaDeleteRequested>(_onDelete);
    on<MediaDescribeRequested>(_onDescribe);
  }

  Future<void> _onLoad(
    MediaLoadRequested event,
    Emitter<MediaState> emit,
  ) async {
    emit(const MediaLoading());
    try {
      final assets = await api.listMedia(projectId);
      emit(MediaLoaded(assets: assets));
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  Future<void> _onSearch(
    MediaSearchRequested event,
    Emitter<MediaState> emit,
  ) async {
    final current = state is MediaLoaded ? state as MediaLoaded : null;
    final assets = current?.assets ?? [];

    if (event.query.trim().isEmpty) {
      emit(MediaLoaded(assets: assets));
      return;
    }

    emit(MediaLoaded(
      assets: assets,
      searchQuery: event.query,
      isSearching: true,
    ));

    try {
      final hits = await api.searchMedia(projectId, event.query);
      emit(MediaLoaded(
        assets: assets,
        searchHits: hits,
        searchQuery: event.query,
        isSearching: false,
      ));
    } catch (e) {
      emit(MediaLoaded(
        assets: assets,
        searchQuery: event.query,
        isSearching: false,
      ));
    }
  }

  Future<void> _onSearchCleared(
    MediaSearchCleared event,
    Emitter<MediaState> emit,
  ) async {
    final current = state is MediaLoaded ? state as MediaLoaded : null;
    emit(MediaLoaded(assets: current?.assets ?? []));
  }

  Future<void> _onUpload(
    MediaUploadRequested event,
    Emitter<MediaState> emit,
  ) async {
    final current = state is MediaLoaded ? state as MediaLoaded : null;
    emit(MediaUploading(current?.assets ?? []));
    try {
      await api.uploadMediaFile(
        projectId: projectId,
        filePath: event.filePath,
        fileName: event.fileName,
      );
      final assets = await api.listMedia(projectId);
      emit(MediaLoaded(assets: assets));
    } catch (e) {
      emit(MediaError(e.toString(), existingAssets: current?.assets ?? []));
    }
  }

  Future<void> _onDelete(
    MediaDeleteRequested event,
    Emitter<MediaState> emit,
  ) async {
    final current = state is MediaLoaded ? state as MediaLoaded : null;
    try {
      await api.deleteMedia(projectId, event.mediaPath);
      final assets = await api.listMedia(projectId);
      emit(MediaLoaded(assets: assets));
    } catch (e) {
      emit(MediaError(e.toString(), existingAssets: current?.assets ?? []));
    }
  }

  Future<void> _onDescribe(
    MediaDescribeRequested event,
    Emitter<MediaState> emit,
  ) async {
    try {
      await api.describeMedia(projectId, event.mediaId);
      final assets = await api.listMedia(projectId);
      final current = state is MediaLoaded ? state as MediaLoaded : null;
      emit(MediaLoaded(
        assets: assets,
        searchHits: current?.searchHits ?? [],
        searchQuery: current?.searchQuery ?? '',
      ));
    } catch (_) {
      // Silently ignore — describe fires async on backend
    }
  }
}
