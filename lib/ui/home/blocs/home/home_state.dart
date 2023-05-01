part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Song> trendingSongs;
  final List<Song> newReleases;

  const HomeState({
    this.status = HomeStatus.initial,
    this.trendingSongs = const [],
    this.newReleases = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Song>? trendingSongs,
    List<Song>? newReleases,
  }) {
    return HomeState(
      status: status ?? this.status,
      trendingSongs: trendingSongs ?? this.trendingSongs,
      newReleases: newReleases ?? this.newReleases,
    );
  }

  @override
  List<Object?> get props => [status, trendingSongs, newReleases];
}
