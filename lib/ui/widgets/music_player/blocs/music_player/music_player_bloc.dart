import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../models/models.dart';
import '../../../../../repositories/song_repository.dart';

part 'music_player_event.dart';
part 'music_player_state.dart';

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final SongRepository _songRepository;

  MusicPlayerBloc({
    required SongRepository songRepository,
  })  : _songRepository = songRepository,
        super(const MusicPlayerState()) {
    on<MusicPlayerStarted>(_onStarted);
    on<MusicPlayerPlay>(_onPlay);
    on<MusicPlayerPause>(_onPause);
    on<MusicPlayerSetCurrentSong>(_onSetCurrentSong);
  }

  void _onStarted(
    MusicPlayerStarted event,
    Emitter<MusicPlayerState> emit,
  ) async {
    await emit.forEach(
      _songRepository.musicPlayerDataStream,
      onData: (data) {
        if (state.status == MusicPlayerStatus.initial &&
            data.currentSong == null) {
          return state.copyWith(
            musicPlayerData: data,
            status: MusicPlayerStatus.initial,
          );
        } else if (state.status == MusicPlayerStatus.initial &&
            data.currentSong != null) {
          return state.copyWith(
            musicPlayerData: data,
            status: MusicPlayerStatus.loaded,
          );
        } else if (state.status == MusicPlayerStatus.paused) {
          return state.copyWith(
            musicPlayerData: data,
            status: MusicPlayerStatus.paused,
          );
        } else if (state.status == MusicPlayerStatus.playing) {
          return state.copyWith(
            musicPlayerData: data,
            status: MusicPlayerStatus.playing,
          );
        } else {
          return state.copyWith(
            musicPlayerData: data,
            status: MusicPlayerStatus.initial,
          );
        }
      },
    );
  }

  void _onPlay(
    MusicPlayerPlay event,
    Emitter<MusicPlayerState> emit,
  ) async {
    _songRepository.play();
    emit(state.copyWith(status: MusicPlayerStatus.playing));
  }

  void _onPause(
    MusicPlayerPause event,
    Emitter<MusicPlayerState> emit,
  ) async {
    _songRepository.pause();
    emit(state.copyWith(status: MusicPlayerStatus.paused));
  }

  void _onSetCurrentSong(
    MusicPlayerSetCurrentSong event,
    Emitter<MusicPlayerState> emit,
  ) async {
    await _songRepository.setCurrentSong(event.song);
    emit(state.copyWith(status: MusicPlayerStatus.initial));
  }
}
