part of '../home_screen.dart';

class _NewReleaseSection extends StatelessWidget {
  const _NewReleaseSection({
    required this.newReleases,
  });

  final List<Song> newReleases;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        print(newReleases);
        return StreamBuilder(
          stream: context.read<SongRepository>().musicPlayerDataStream,
          builder: (context, snapshot) {
            Song? currentSong;
            AudioPlayerState? audioPlayerState;
            if (snapshot.hasData) {
              final musicPlayerData = snapshot.data as MusicPlayerData;
              currentSong = musicPlayerData.currentSong;
              audioPlayerState = (musicPlayerData.playbackState.playing == true)
                  ? AudioPlayerState.playing
                  : AudioPlayerState.paused;
            }
            return AppList.horizontal(
              title: AppText('New Release from '),
              description: AppText('Artist Name here'),
              listItems: newReleases
                  .map(
                    (song) => AppListTile(
                      width: size.width * 0.8,
                      contentPadding: EdgeInsets.zero,
                      leadingWidth: size.width * 0.30,
                      leading: AppImage.network(
                        song.imageUrl,
                        height: size.width * 0.30,
                      ),
                      title: AppText(song.title),
                      subtitle: AppText(song.artist.name),
                      trailing: AppIconButton(
                        onPressed: () {
                          if (song.id == currentSong?.id &&
                              audioPlayerState == AudioPlayerState.playing) {
                            context.read<SongRepository>().pause();
                          } else {
                            context.read<SongRepository>().setCurrentSong(song);
                            context.read<SongRepository>().play();
                          }
                        },
                        child: const Icon(Icons.play_arrow),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }
}
