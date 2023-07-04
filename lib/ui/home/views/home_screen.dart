import 'package:atomsbox/atomsbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../download.dart';
import '../../../models/music_player_data.dart';
import '../../../models/song.dart';
import '../../../repositories/song_repository.dart';
import '../../widgets/music_player/music_player.dart';
import '../../widgets/widgets.dart';
import '../blocs/home/home_bloc.dart';

part 'widgets/_trending_songs_section.dart';
part 'widgets/_new_releases_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        songRepository: context.read<SongRepository>(),
      )..add(HomeStarted()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: AppText.headlineSmall('Good evening!'),
      ),
      bottomNavigationBar: const BottomNavBar(index: 0),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const MusicPlayer(dense: true),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading ||
              state.status == HomeStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HomeStatus.loaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TrendingSongsSection(trendingSongs: state.trendingSongs),
                    const SizedBox(height: AppConstants.lg),
                    _NewReleaseSection(newReleases: state.newReleases),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: AppText('Something went wrong'));
          }
        },
      ),
    );
  }
}
