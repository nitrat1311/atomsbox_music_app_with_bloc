import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../models/models.dart';
import '../../../../repositories/song_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SongRepository _songRepository;

  HomeBloc({
    required SongRepository songRepository,
  })  : _songRepository = songRepository,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  void _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    final songs = await _songRepository.getSongs();
    emit(
      state.copyWith(
        trendingSongs: songs?.take(6).toList(),
        newReleases: songs?.take(3).toList(),
        status: HomeStatus.loaded,
      ),
    );
  }
}
