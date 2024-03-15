import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:online_music_player/main.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/models/song_fetch.dart';
import 'package:online_music_player/pages/artist.dart';
import 'package:online_music_player/pages/songpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static int musicindex = 0;
  static int id = 0;
  static String title = '', subtitle = '';
  static String img = '';

  static late ConcatenatingAudioSource playlist;
  List<Song> trackUrls = [];
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (globalclass.songs.isEmpty) {
      getData().whenComplete(() {
        _filterItems();
        if (mounted) {
          setState(() {});
        }
      });
    }
    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }
    super.initState();
    

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) player.pause();
    super.didChangeAppLifecycleState(state);
  }

  void _filterItems() {
    setState(() {
      if (globalclass.songs.isEmpty) {
        globalclass.songs.clear();
      } else {
        globalclass.bengali = globalclass.songs
            .where((item) => item.genre.toLowerCase().contains('bengali'))
            .toList();
        globalclass.hindi = globalclass.songs
            .where((item) => item.genre.toLowerCase().contains('hindi'))
            .toList();
      }
    });
  }

  List<AudioSource> buildPlaylist(song) {
    setState(() {
      trackUrls = song;
    });
    List<AudioSource> playlist = [];
    playlist.clear();

    for (int i = 0; i < trackUrls.length; i++) {
      try {
        playlist.add(
          AudioSource.uri(
            Uri.parse(MyUrl.fullurl + trackUrls[i].filepath),
            tag: MediaItem(
              id: trackUrls[i].id,
              album: trackUrls[i].lyrics,
              title: trackUrls[i].title,
              artist: trackUrls[i].singer,
              genre: trackUrls[i].genre,
              displayDescription: trackUrls[i].filepath,
              duration: Duration(minutes: int.parse(trackUrls[i].duration)),
              artUri: Uri.parse(MyUrl.fullurl + trackUrls[i].image),
            ),
          ),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
    setState(() {});
    return playlist;
  }

  Future<dynamic> getData() async {
    try {
      final response =
          await http.get(Uri.parse('${MyUrl.fullurl}song_fetch.php'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        globalclass.songs.clear();
        for (int i = 0; i < data.length; i++) {
          setState(() {});
          Song song = Song(
            title: data[i]['title'],
            singer: data[i]['singer'],
            genre: data[i]['genre'],
            filepath: data[i]['file_path'],
            duration: data[i]['duration'],
            id: data[i]['id'],
            image: data[i]['image'],
            lyrics: data[i]['lyrics'],
          );
          globalclass.songs.add(song);
        }
      } else {
        // ignore: avoid_print
        print('Failed to fetch music data');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static List<Song> listsong = [];

  static Song songclass = Song(
      id: 'id',
      title: 'title',
      singer: 'singer',
      genre: 'genre',
      duration: 'duration',
      filepath: 'file_path',
      image: 'image',
      lyrics: 'lyrics');

  // Future refresh() async {
  //   if (SongPageState.isPlayerInitialized == false) {
  //     setState(() {
  //       globalclass.songs.clear();
  //       globalclass.bengali.clear();
  //       globalclass.hindi.clear();
  //       FocusScope.of(context).unfocus();
  //     });
  //     await getData().whenComplete(() => _filterItems());
  //   }
  // }

  Future refresh() async {
    globalclass.songs.clear();
    globalclass.bengali.clear();
    globalclass.hindi.clear();
    await getData().whenComplete(() => _filterItems());
    setState(() {});
  }

  List items = [
    '${MyUrl.fullurl}artist/Arijit_Singh.jpg',
    '${MyUrl.fullurl}artist/Shreya_Ghoshal.jpg',
    '${MyUrl.fullurl}artist/king.jpg',
    '${MyUrl.fullurl}artist/KK.jpg'
  ];

  List name = ['Arijit Singh', 'Shreya Ghoshal', 'King', 'KK'];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: RefreshIndicator(
          color: Colors.black,
          onRefresh: () => refresh(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 3, bottom: 10, left: 5),
                              child: Text(
                                'Recommended Artists Stations',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Inter",
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        margin: const EdgeInsets.only(
                                            right: 10, top: 0, bottom: 5),
                                        child: CircularProfileAvatar(
                                          items[index],
                                          borderWidth: 5,
                                          backgroundColor: Colors.transparent,
                                          imageFit: BoxFit.cover,
                                          showInitialTextAbovePicture: true,
                                          elevation: 5.0,
                                          progressIndicatorBuilder: (context,
                                                  url, progress) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          cacheImage: true,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          onTap: () {
                                            Get.to(
                                                () => Artist(
                                                    name[index], items[index]),
                                                transition: Transition
                                                    .rightToLeftWithFade);
                                          },
                                        )),
                                    Text(
                                      name[index],
                                    )
                                  ],
                                );
                              }),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 3, bottom: 10, left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hindi Song',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ),
                        globalclass.hindi.isNotEmpty
                            ? Container(
                                height: 190,
                                alignment: Alignment.center,
                                child: ListView.builder(
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: globalclass.hindi.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, right: 4),
                                        child: InkWell(
                                          onTap: () {
                                            SongPageState.beforeid = 0;
                                            setState(() {
                                              player.seek(Duration.zero,
                                                  index: index);
                                              playlist =
                                                  ConcatenatingAudioSource(
                                                      children: buildPlaylist(
                                                          globalclass.hindi));

                                              songclass =
                                                  globalclass.hindi[index];
                                              listsong = globalclass.hindi;
                                              id = int.parse(songclass.id);
                                              musicindex = index;

                                              // img = MyUrl.fullurl +
                                              //     songclass.image;
                                              // title = globalclass
                                              //     .hindi[index].title;
                                              // subtitle = globalclass
                                              //     .hindi[index].singer;
                                              // globalclass.controller.add(true);

                                              Get.to(
                                                  () => SongPage(
                                                      HomePageState.playlist,
                                                      index,
                                                      id,
                                                      HomePageState.listsong),
                                                  transition:
                                                      Transition.downToUp);
                                            });
                                          },
                                          child: SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: CachedNetworkImage(
                                                      imageUrl: MyUrl.fullurl +
                                                          globalclass
                                                              .hindi[index]
                                                              .image,
                                                      placeholder:
                                                          (context, url) =>
                                                              const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Container(
                                                          height: 150,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: Colors.white,
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text(
                                                      globalclass
                                                          .hindi[index].title,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(top: 70, bottom: 70),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bengali Song',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        globalclass.bengali.isNotEmpty
                            ? Container(
                                height: 190,
                                alignment: Alignment.center,
                                child: ListView.builder(
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: globalclass.bengali.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, right: 4),
                                        child: InkWell(
                                          onTap: () {
                                            SongPageState.beforeid = 0;
                                            setState(() {
                                              player.seek(Duration.zero,
                                                  index: index);
                                              playlist =
                                                  ConcatenatingAudioSource(
                                                      children: buildPlaylist(
                                                          globalclass.bengali));

                                              songclass =
                                                  globalclass.bengali[index];
                                              listsong = globalclass.bengali;
                                              id = int.parse(songclass.id);
                                              musicindex = index;

                                              // img = MyUrl.fullurl +
                                              //     songclass.image;
                                              // title = globalclass
                                              //     .bengali[index].title;
                                              // subtitle = globalclass
                                              //     .bengali[index].singer;
                                              // globalclass.controller.add(true);

                                              Get.to(
                                                  () => SongPage(
                                                      HomePageState.playlist,
                                                      index,
                                                      id,
                                                      HomePageState.listsong),
                                                  transition:
                                                      Transition.downToUp);
                                            });
                                          },
                                          child: SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: CachedNetworkImage(
                                                      imageUrl: MyUrl.fullurl +
                                                          globalclass
                                                              .bengali[index]
                                                              .image,
                                                      placeholder:
                                                          (context, url) =>
                                                              const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Container(
                                                          height: 150,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: Colors.white,
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text(
                                                      globalclass
                                                          .bengali[index].title,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(top: 70, bottom: 70),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        globalclass.songs.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                primary: false,
                                itemCount: globalclass.songs.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    key: UniqueKey(),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 35,
                                      child: CachedNetworkImage(
                                        imageUrl: MyUrl.fullurl +
                                            globalclass.songs[index].image,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                image: DecorationImage(
                                                    image: imageProvider)),
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      globalclass.songs[index].title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      globalclass.songs[index].singer,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    onTap: () {
                                      SongPageState.beforeid = 0;
                                      setState(() {
                                        player.seek(Duration.zero,
                                            index: index);
                                        playlist = ConcatenatingAudioSource(
                                            children: buildPlaylist(
                                                globalclass.songs));

                                        songclass = globalclass.songs[index];
                                        listsong = globalclass.songs;
                                        id = int.parse(songclass.id);
                                        musicindex = index;

                                        // img = MyUrl.fullurl + songclass.image;
                                        // title = globalclass.songs[index].title;
                                        // subtitle =
                                        //     globalclass.songs[index].singer;
                                        // globalclass.controller.add(true);

                                        Get.to(
                                            () => SongPage(
                                                HomePageState.playlist,
                                                index,
                                                id,
                                                HomePageState.listsong),
                                            transition: Transition.downToUp);
                                      });
                                    },
                                  );
                                },
                              )
                            : const Padding(
                                padding: EdgeInsets.only(top: 100, bottom: 70),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                      ],
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
