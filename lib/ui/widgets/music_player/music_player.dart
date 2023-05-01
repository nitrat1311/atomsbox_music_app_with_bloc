import 'package:atomsbox/atomsbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/models.dart';
import 'blocs/music_player/music_player_bloc.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, this.onTap, this.dense = false});

  final bool dense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MusicPlayerBloc, MusicPlayerState>(
      listener: (context, state) {
        if (state.status == MusicPlayerStatus.initial) {
          return;
        } else if (state.status == MusicPlayerStatus.loaded) {
          context.read<MusicPlayerBloc>().add(MusicPlayerPlay());
        }
      },
      builder: (context, state) {
        if (state.status == MusicPlayerStatus.initial) {
          return const SizedBox();
        } else {
          MusicPlayerData data = state.musicPlayerData!;
          AudioPlayerState audioPlayerState = AudioPlayerState.stopped;

          if (state.musicPlayerData!.playbackState.playing == true) {
            audioPlayerState = AudioPlayerState.playing;
          } else if (state.musicPlayerData!.playbackState.playing == false) {
            audioPlayerState = AudioPlayerState.paused;
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.sm),
            child: AppAudioCard.dense(
              songName: data.currentSong!.title,
              artistName: data.currentSong!.artist.name,
              imageUrl: data.currentSong!.imageUrl,
              songUrl: data.currentSong!.songUrl,
              audioPlayerState: audioPlayerState,
              play: () =>
                  context.read<MusicPlayerBloc>().add(MusicPlayerPlay()),
              pause: () =>
                  context.read<MusicPlayerBloc>().add(MusicPlayerPause()),
              position:
                  state.musicPlayerData?.currentSongPosition ?? Duration.zero,
              duration:
                  state.musicPlayerData?.currentSongDuration ?? Duration.zero,
            ),
          );
        }
      },
    );
  }
}
