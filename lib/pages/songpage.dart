import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:online_music_player/main.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/models/notification.dart';
import 'package:online_music_player/models/song_fetch.dart';
import 'package:online_music_player/pages/common.dart';
import 'package:online_music_player/pages/homepage.dart';
import 'package:online_music_player/pages/loadingdialog.dart';
import 'package:online_music_player/pages/neu_box.dart';
import 'package:readmore/readmore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SongPage extends StatefulWidget {
  ConcatenatingAudioSource playlist;
  int musicindex;
  int id;
  List<Song> listsong = [];
  SongPage(this.playlist, this.musicindex, this.id, this.listsong, {Key? key})
      : super(key: key);

  @override
  SongPageState createState() => SongPageState(playlist);
}

class SongPageState extends State<SongPage> with WidgetsBindingObserver {
  static bool isPlayerInitialized = false;
  ConcatenatingAudioSource playlist;
  SongPageState(this.playlist);

  late SharedPreferences sp;

  static int beforeid = 0;
  static int beforeindex = 0;

  @override
  void initState() {
    Noti.initialize(globalclass.flutterLocalNotificationsPlugin);
    super.initState();
    playmusic();
  }

  Future playmusic() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (beforeid == widget.id &&
          beforeindex == widget.musicindex &&
          isPlayerInitialized == true) {
        // player.play();
      } else {
        isPlayerInitialized = true;
        beforeid = widget.id;
        beforeindex = widget.musicindex;
        _init().whenComplete(() => null);
      }
    });
  }

  @override
  void dispose() {
    globalclass.controller.add(true);
    super.dispose();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      setState(() async {
        sp = await SharedPreferences.getInstance();
        bool suffle = sp.getBool('suffle') ?? false;
        int loop = sp.getInt('loop') ?? 0;
        await player
            .setAudioSource(
          playlist,
          preload: true,
          initialIndex: widget.musicindex,
          initialPosition: Duration.zero,
        )
            .whenComplete(() {
          if (loop == 0) {
            player.setLoopMode(LoopMode.all);
          } else if (loop == 2) {
            player.setLoopMode(LoopMode.off);
          } else {
            player.setLoopMode(LoopMode.one);
          }

          suffle == true ? player.setShuffleModeEnabled(suffle) : null;
          player.play();
        });
      });
    // ignore: unused_catch_stack
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  late MediaItem metadata = MediaItem(id: ' ', title: ' ');

  var filePath;
  bool downloading = false;

  checkDownloadfile(musicUrl) async {
    var name = metadata.title;

    showDialog(
        context: context,
        builder: (context) {
          return LoadingDialog();
        });
    try {
      final response = await http.get(Uri.parse(MyUrl.fullurl + musicUrl));

      if (response.statusCode == 200) {
        String filename = name + DateTime.now().microsecond.toString();
        filePath = '/storage/emulated/0/Download/$filename.mp3';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }

        Noti.showBigTextNotification(
            title: "$name",
            body: "Music Downloaded Successfully",
            fln: globalclass.flutterLocalNotificationsPlugin);
      } else {
        Noti.showBigTextNotification(
            title: "$name",
            body: "Music Downloaded failed",
            fln: globalclass.flutterLocalNotificationsPlugin);
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }
      }
    } catch (e) {
      Noti.showBigTextNotification(
          title: "$name",
          body: "Music Downloaded failed",
          fln: globalclass.flutterLocalNotificationsPlugin);
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> _requestNotificationPermissions() async {
    final bool? granted = await globalclass.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (granted != null && granted) {
    } else {}
  }

  Widget imageProfile() {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;

            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }
            metadata = state?.currentSource!.tag as MediaItem;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            width: MediaQuery.sizeOf(context).height * 1.5,
                            imageUrl: metadata.artUri.toString(),
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image:
                                        DecorationImage(image: imageProvider)),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metadata.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textHeightBehavior: const TextHeightBehavior(),
                              style: const TextStyle(
                                  color: Colors.cyan, fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                '${metadata.artist}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                ),
                Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      child: Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Genre: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${metadata.genre}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontFamily: 'Inter',
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      child: Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Duration: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          metadata.duration?.inMinutes != null
                              ? Flexible(
                                  child: Text(
                                    '${metadata.duration?.inHours} minutes and ${metadata.duration?.inMinutes.remainder(60).toString().padLeft(2, '0')} seconds',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                )
                              : const Flexible(
                                  child: Text('None',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Inter',
                                      )),
                                ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      child: Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Lyrics: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: SizedBox(
                              width: 250,
                              child: ReadMoreText(
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                ),
                                '${metadata.album}',
                                textAlign: TextAlign.justify,
                                trimLines: 2,
                                colorClickableText: Colors.pink,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'Show more',
                                trimExpandedText: 'Show less',
                                moreStyle: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _requestNotificationPermissions().whenComplete(() {
                          setState(() {
                            downloading = true;
                          });
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Allow Music to download this audio file?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: CachedNetworkImage(
                                      imageUrl: metadata.artUri.toString()),
                                  actions: [
                                    ElevatedButton(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.red)),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Deny',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await await checkDownloadfile(
                                              metadata.displayDescription);
                                        },
                                        child: const Text(
                                          'Allow',
                                          style: TextStyle(color: Colors.black),
                                        ))
                                  ],
                                );
                              });
                          ;
                        });
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.file_download_rounded,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Download',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Share.share(
                            '${MyUrl.fullurl}${metadata.displayDescription}');
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Share',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static int musiccount = 0;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  // back button and menu button
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: NeuBox(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back))),
                        ),
                        const Text('P L A Y L I S T'),
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: NeuBox(
                              child: IconButton(
                                  onPressed: () {
                                    showSlidingBox(
                                      context: context,
                                      box: SlidingBox(
                                          color: const Color.fromARGB(
                                              255, 51, 57, 72),
                                          maxHeight: 500,
                                          collapsed: true,
                                          backdrop: const Backdrop(),
                                          body: imageProfile()),
                                    );
                                  },
                                  icon: const Icon(Icons.menu))),
                        ),
                      ],
                    ),
                  ),
                  //cover art, song name, artist name
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        StreamBuilder<SequenceState?>(
                          stream: player.sequenceStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;

                            if (state?.sequence.isEmpty ?? true) {
                              return const SizedBox();
                            }

                            metadata = state?.currentSource!.tag as MediaItem;
                            return NeuBox(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      height: 250,
                                      width: 250,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: metadata.artUri.toString(),
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                    image: imageProvider)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      metadata.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      metadata.artist!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  //Adjust volume, repeat button, shuffle button,Adjust Speed
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              showSliderDialog(
                                context: context,
                                title: "Adjust volume",
                                divisions: 10,
                                min: 0.0,
                                max: 1.0,
                                value: player.volume,
                                stream: player.volumeStream,
                                onChanged: player.setVolume,
                              );
                            });
                          },
                        ),
                        StreamBuilder<LoopMode>(
                          stream: player.loopModeStream,
                          builder: (context, snapshot) {
                            final loopMode = snapshot.data ?? LoopMode.off;

                            const icons = [
                              Icon(Icons.repeat, color: Colors.orange),
                              Icon(Icons.repeat, color: Colors.black),
                              Icon(Icons.repeat_one, color: Colors.orange),
                            ];
                            const cycleModes = [
                              LoopMode.off,
                              LoopMode.all,
                              LoopMode.one,
                            ];
                            final index = cycleModes.indexOf(loopMode);
                            return IconButton(
                              icon: icons[index],
                              onPressed: () async {
                                sp = await SharedPreferences.getInstance();
                                player.setLoopMode(cycleModes[
                                    (cycleModes.indexOf(loopMode) + 1) %
                                        cycleModes.length]);
                                sp.setInt('loop', index);
                                if (index == 0) {
                                  Fluttertoast.showToast(msg: 'Loopmode all');
                                } else if (index == 1)
                                  Fluttertoast.showToast(msg: 'Loopmode one');
                                else
                                  Fluttertoast.showToast(msg: 'Loopmode off');
                              },
                            );
                          },
                        ),
                        StreamBuilder<bool>(
                          stream: player.shuffleModeEnabledStream,
                          builder: (context, snapshot) {
                            final shuffleModeEnabled = snapshot.data ?? false;
                            return IconButton(
                              icon: shuffleModeEnabled
                                  ? const Icon(Icons.shuffle,
                                      color: Colors.orange)
                                  : const Icon(Icons.shuffle,
                                      color: Colors.black),
                              onPressed: () async {
                                sp = await SharedPreferences.getInstance();
                                final enable = !shuffleModeEnabled;
                                sp.setBool('suffle', enable);
                                if (enable) {
                                  await player.shuffle();
                                }

                                await player.setShuffleModeEnabled(enable);
                                Fluttertoast.showToast(
                                    msg: 'Shuffle mode ' + enable.toString());
                              },
                            );
                          },
                        ),
                        StreamBuilder<double>(
                          stream: player.speedStream,
                          builder: (context, snapshot) => IconButton(
                            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            onPressed: () {
                              showSliderDialog(
                                context: context,
                                title: "Adjust speed",
                                divisions: 10,
                                min: 0.5,
                                max: 1.5,
                                value: player.speed,
                                stream: player.speedStream,
                                onChanged: player.setSpeed,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return NeuBox(
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbColor: const Color.fromARGB(255, 243,
                                        33, 33), // Customize the thumb color
                                    overlayColor:
                                        const Color.fromARGB(255, 243, 33, 33),
                                    activeTrackColor: const Color.fromARGB(
                                        255,
                                        239,
                                        46,
                                        46), // Customize the active track (duration) color
                                    inactiveTrackColor: Colors.black26,
                                  ),
                                  //Slider
                                  child: Slider(
                                    min: 0.0,
                                    max: positionData?.duration.inSeconds
                                            .toDouble() ??
                                        Duration.zero.inSeconds.toDouble(),
                                    divisions: 1000,
                                    label: positionData?.position.inSeconds
                                        .toString()
                                        .padLeft(2, '0'),
                                    value: (positionData?.position.inSeconds
                                                .toDouble()) ==
                                            null
                                        ? Duration.zero.inSeconds.toDouble()
                                        : (min(
                                            (positionData!.position.inSeconds
                                                .toDouble()),
                                            (positionData.duration.inSeconds
                                                .toDouble()))),
                                    onChanged: (double newPosition) {
                                      positionData!.duration.inSeconds
                                              .toString()
                                              .isNotEmpty
                                          ? player.seek(Duration(
                                              seconds: newPosition.toInt()))
                                          : player
                                              .seek(const Duration(seconds: 0));
                                    },
                                    semanticFormatterCallback: (double value) {
                                      return '${positionData?.position.inSeconds.toString().padLeft(2, '0')} / ${positionData?.bufferedPosition ?? Duration.zero}';
                                    },
                                  ),
                                ),
                                // start time, end time
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 25),
                                      child: positionData?.position.inSeconds !=
                                              null
                                          ? Text(
                                              '${positionData?.position.inMinutes.toString().padLeft(2, '0')}.${positionData?.position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )
                                          : Text(
                                              '${Duration.zero.inMinutes.toString().padLeft(2, '0')}.${Duration.zero.inSeconds.toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 25),
                                      child: positionData?.duration.inSeconds !=
                                              null
                                          ? Text(
                                              '${positionData?.duration.inMinutes.toString().padLeft(2, '0')}.${positionData?.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )
                                          : Text(
                                              '${Duration.zero.inMinutes.toString().padLeft(2, '0')}.${Duration.zero.inSeconds.toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // previous song, pause play, skip next song
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          StreamBuilder<SequenceState?>(
                            stream: player.sequenceStateStream,
                            builder: (context, snapshot) {
                              return Flexible(
                                child: NeuBox(
                                  child: IconButton(
                                      iconSize: 32,
                                      color: Colors.black,
                                      icon: player.hasPrevious
                                          ? Visibility(
                                              visible: player.hasPrevious,
                                              child: const Icon(
                                                  Icons.skip_previous_rounded))
                                          : Visibility(
                                              visible: player.hasPrevious,
                                              child: const Icon(
                                                  Icons.skip_previous_rounded)),
                                      onPressed: () {
                                        player.hasPrevious
                                            ? player.seekToPrevious()
                                            : null;
                                      }),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                globalclass.controller.add(true);
                              });
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Flexible(
                                  flex: 2,
                                  child: NeuBox(
                                    child: Container(
                                      margin: const EdgeInsets.all(8.0),
                                      width: 32.0,
                                      height: 32.0,
                                      child: const CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              } else if (playing != true) {
                                return Flexible(
                                  flex: 2,
                                  child: NeuBox(
                                    child: IconButton(
                                        icon: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.black),
                                        iconSize: 32.0,
                                        onPressed: () {
                                          player.play();
                                        }),
                                  ),
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return Flexible(
                                  flex: 2,
                                  child: NeuBox(
                                    child: IconButton(
                                      icon: const Icon(Icons.pause_rounded,
                                          color: Colors.black),
                                      iconSize: 32.0,
                                      onPressed: player.pause,
                                    ),
                                  ),
                                );
                              } else {
                                return Flexible(
                                  flex: 2,
                                  child: NeuBox(
                                    child: IconButton(
                                      icon: const Icon(Icons.replay,
                                          color: Colors.black),
                                      iconSize: 32.0,
                                      onPressed: () => player.seek(
                                          Duration.zero,
                                          index:
                                              player.effectiveIndices!.first),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          StreamBuilder<SequenceState?>(
                            stream: player.sequenceStateStream,
                            builder: (context, snapshot) {
                              return Flexible(
                                child: NeuBox(
                                  child: IconButton(
                                    iconSize: 32,
                                    color: Colors.black,
                                    icon: player.hasNext
                                        ? Visibility(
                                            visible: player.hasNext,
                                            child: const Icon(
                                                Icons.skip_next_rounded))
                                        : Visibility(
                                            visible: player.hasNext,
                                            child: const Icon(
                                                Icons.skip_next_rounded)),
                                    onPressed: () {
                                      player.hasNext
                                          ? player.seekToNext()
                                          : null;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: StreamBuilder<SequenceState?>(
                      stream: player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        final sequence = state?.sequence ?? [];
                        globalclass.controller.add(true);
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: sequence.length,
                            itemBuilder: (context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: NeuBox(
                                  child: Container(
                                    key: ValueKey(sequence[index]),
                                    color: index == state!.currentIndex
                                        ? const Color.fromARGB(255, 3, 103, 161)
                                            .withAlpha(100)
                                        : null,
                                    child: ListTile(
                                      title: Text(
                                        sequence[index].tag.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      leading: CircleAvatar(
                                        radius: 30,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${sequence[index].tag.artUri}',
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          imageBuilder:
                                              (context, imageProvider) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.fill)),
                                            );
                                          },
                                        ),
                                      ),
                                      trailing: Text(
                                        index == state.currentIndex &&
                                                player.playing
                                            ? 'Playing'
                                            : '',
                                        style: const TextStyle(
                                            color: Colors.cyanAccent),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          HomePageState.songclass =
                                              widget.listsong[index];
                                          globalclass.controller.add(true);
                                        });
                                        player.seek(Duration.zero,
                                            index: index);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
