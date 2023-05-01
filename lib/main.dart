import 'package:atomsbox/atomsbox.dart';
import 'package:audio_handler/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/song_repository.dart';
import 'ui/home/views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AudioHandler audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
        // androidNotificationChannelId: 'com.mycompany.myapp.audio',
        // androidNotificationChannelName: 'Audio Service Demo',
        // androidNotificationOngoing: true,
        // androidStopForegroundOnPause: true,
        ),
  );

  runApp(MyApp(audioHander: audioHandler));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required AudioHandler audioHander})
      : _audioHandler = audioHander;

  final AudioHandler _audioHandler;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SongRepository>(
          create: (context) => SongRepository(audioHandler: _audioHandler),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
