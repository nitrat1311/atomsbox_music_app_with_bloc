
import 'dart:io';

import 'package:atomsbox_music_app_with_bloc/snackbar.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ext_storage_provider.dart';
import 'models/song.dart';

class Download with ChangeNotifier {
  static final Map<String, Download> _instances = {};
  final String id;

  factory Download(String id) {
    if (_instances.containsKey(id)) {
      return _instances[id]!;
    } else {
      final instance = Download._internal(id);
      _instances[id] = instance;
      return instance;
    }
  }

  Download._internal(this.id);

  int? rememberOption;
  final ValueNotifier<bool> remember = ValueNotifier<bool>(false);

  String downloadFormat = 'm4a';
  bool createDownloadFolder = false;
  double? progress = 0.0;
  String lastDownloadId = '';
  bool download = true;

  Future<void> prepareDownload(
    BuildContext context,
    Song data, {
    bool createFolder = false,
    String? folderName,
  }) async {
    Logger.root.info('Preparing download for ${data.title}');
    download = true;
    if (Platform.isAndroid || Platform.isIOS) {
      Logger.root.info('Requesting storage permission');
      PermissionStatus status = await Permission.storage.status;
      if (status.isDenied) {
        Logger.root.info('Request denied');
        await [
          Permission.storage,
          Permission.accessMediaLocation,
          Permission.mediaLibrary,
        ].request();
      }
      status = await Permission.storage.status;
      if (status.isPermanentlyDenied) {
        Logger.root.info('Request permanently denied');
        await openAppSettings();
      }
    }


    String dlPath =
        Hive.box('settings').get('downloadPath', defaultValue: '') as String;
    Logger.root.info('Cached Download path: $dlPath');

    if (dlPath == '') {
      Logger.root.info('Cached Download path is empty, getting new path');
      final String? temp = await ExtStorageProvider.getExtStorage(
        dirName: 'Music',
        writeAccess: true,
      );
      dlPath = temp!;
    }
    Logger.root.info('New Download path: $dlPath');

    if (createFolder && createDownloadFolder && folderName != null) {
      final String foldername = '1';
      dlPath = '$dlPath/$foldername';
      if (!await Directory(dlPath).exists()) {
        Logger.root.info('Creating folder $foldername');
        await Directory(dlPath).create();
      }
    }

    final bool exists = await File('$dlPath/${data.title}').exists();
    if (exists) {
      Logger.root.info('File already exists');
      if (remember.value == true && rememberOption != null) {
        switch (rememberOption) {
          case 0:
            lastDownloadId = data.id.toString();
            break;
          case 1:
            downloadSong(context, dlPath, data.title, data);
            break;
          case 2:
            while (await File('$dlPath/${data.title}').exists()) {
          print('download error');
            }
            break;
          default:
            lastDownloadId = data.title;
            break;
        }
      } 
    } else {
      downloadSong(context, dlPath, data.title, data);
    }
  }

  Future<void> downloadSong(
    BuildContext context,
    String? dlPath,
    String fileName,
    Song data,
  ) async {
    Logger.root.info('processing download');
    progress = null;
    notifyListeners();
    String? filepath;
    String? appPath;
    final List<int> bytes = [];


      Logger.root.info('Getting App Path for storing image');
      appPath = Hive.box('settings').get('tempDirPath')?.toString();
      appPath ??= (await getTemporaryDirectory()).path;
  

    try {
      Logger.root.info('Creating audio file $dlPath/$fileName');
      await File('$dlPath/$fileName')
          .create(recursive: true)
          .then((value) => filepath = value.path);
    } catch (e) {
      Logger.root
          .info('Error creating files, requesting additional permission');
      if (Platform.isAndroid) {
        PermissionStatus status = await Permission.manageExternalStorage.status;
        if (status.isDenied) {
          Logger.root.info(
            'ManageExternalStorage permission is denied, requesting permission',
          );
          await [
            Permission.manageExternalStorage,
          ].request();
        }
        status = await Permission.manageExternalStorage.status;
        if (status.isPermanentlyDenied) {
          Logger.root.info(
            'ManageExternalStorage Request is permanently denied, opening settings',
          );
          await openAppSettings();
        }
      }

      Logger.root.info('Retrying to create audio file');
      await File('$dlPath/$fileName')
          .create(recursive: true)
          .then((value) => filepath = value.path);

    }

    Logger.root.info('Connecting to Client');
    final client = Client();
    final response = await client.send(Request('GET', Uri.parse('https://drive.google.com/uc?export=view&id=1f3snxeEBXHUuAF2Upbhl0I8cw3__KBnc')));
    final int total = response.contentLength ?? 0;
    int recieved = 0;
    Logger.root.info('Client connected, Starting download');
    response.stream.asBroadcastStream();
    Logger.root.info('broadcasting download state');
    response.stream.listen((value) {
      bytes.addAll(value);
      try {
        recieved += value.length;
        progress = recieved / total;
        notifyListeners();
        if (!download) {
          client.close();
        }
      } catch (e) {
        Logger.root.severe('Error in download: $e');
      }
    }).onDone(() async {
      if (download) {
        Logger.root.info('Download complete, modifying file');
        final file = File(filepath!);
        await file.writeAsBytes(bytes);
        }
        Logger.root.info('Closing connection & notifying listeners');
        client.close();
        lastDownloadId = data.id;
        progress = 0.0;
        notifyListeners();

        Logger.root.info('Putting data to downloads database');
        final songData = {
          'id': data.id,
      
          'path': filepath,
        };
        Hive.box('downloads').put(songData['id'].toString(), songData);
    
        Logger.root.info('Everything done, showing snackbar');
        ShowSnackBar().showSnackBar(
          context,
          // '"${data['title']}" ${AppLocalizations.of(context)!.downed}',
          'downloaded',
        );
    
    });
  }
}

class DownloadButton extends StatefulWidget {
  final Song data;
  final String? icon;
  final double? size;
  const DownloadButton({
    super.key,
    required this.data,
    this.icon,
    this.size,
  });

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  late Download down;
  final Box downloadsBox = Hive.box('downloads');
  final ValueNotifier<bool> showStopButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    down = Download('1');
    down.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: Center(
        child: (downloadsBox.containsKey(widget.data.id))
            ? IconButton(
                icon: const Icon(Icons.download_done_rounded),
                tooltip: 'Download Done',
                color: Theme.of(context).colorScheme.secondary,
                iconSize: widget.size ?? 24.0,
                onPressed: () {
                  down.prepareDownload(context, widget.data);
                },
              )
            : down.progress == 0
                ? IconButton(
                    icon: Icon(
                      widget.icon == 'download'
                          ? Icons.download_rounded
                          : Icons.save_alt,
                    ),
                    iconSize: widget.size ?? 24.0,
                    color: Theme.of(context).iconTheme.color,
                    tooltip: 'Download',
                    onPressed: () {
                      down.prepareDownload(context, widget.data);
                    },
                  )
                : GestureDetector(
                    child: Stack(
                      children: [
                        Center(
                          child: CircularProgressIndicator(
                            value: down.progress == 1 ? null : down.progress,
                          ),
                        ),
                        Center(
                          child: ValueListenableBuilder(
                            valueListenable: showStopButton,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                                iconSize: 25.0,
                                color: Theme.of(context).iconTheme.color,
                                tooltip: 'stop_down',
                                // AppLocalizations.of(
                                //   context,
                                // )!
                                //     .stopDown,
                                onPressed: () {
                                  down.download = false;
                                },
                              ),
                            ),
                            builder: (
                              BuildContext context,
                              bool showValue,
                              Widget? child,
                            ) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible: !showValue,
                                      child: Center(
                                        child: Text(
                                          down.progress == null
                                              ? '0%'
                                              : '${(100 * down.progress!).round()}%',
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: showValue,
                                      child: child!,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      showStopButton.value = true;
                      Future.delayed(const Duration(seconds: 2), () async {
                        showStopButton.value = false;
                      });
                    },
                  ),
      ),
    );
  }
}