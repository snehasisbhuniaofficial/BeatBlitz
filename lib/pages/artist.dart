import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:online_music_player/main.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/pages/homepage.dart';
import 'package:online_music_player/pages/songpage.dart';
import 'package:online_music_player/models/song_fetch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;

// ignore: must_be_immutable
class Artist extends StatefulWidget {
  String name;
  String image;
  Artist(this.name, this.image, {super.key});

  @override
  State<Artist> createState() => _ArtistState(name, image);
}

class _ArtistState extends State<Artist> {
  String name;
  String image;
  _ArtistState(this.name, this.image);

  @override
  void initState() {
    super.initState();
    _filterItems(name)
        .whenComplete(() => buildPlaylist(globalclass.artist));
  }

  Future _filterItems(String name) async {
    setState(() {
      name = name.toLowerCase();
      if (globalclass.songs.isEmpty) {
        globalclass.songs.clear();
      } else {
        globalclass.artist = globalclass.songs
            .where((item) => item.singer.toLowerCase().contains(name))
            .toList();
      }
    });
  }

  int totalduration = 0;
  List<Song> trackUrls = [];
  Duration totalDuration = const Duration();
  List<AudioSource> buildPlaylist(song) {
    setState(() {
      trackUrls = song;
    });
    List<AudioSource> playlist = [];
    playlist.clear();

    for (int i = 0; i < trackUrls.length; i++) {
      playlist.add(
        AudioSource.uri(
          Uri.parse(MyUrl.fullurl + trackUrls[i].filepath),
          tag: MediaItem(
            id: trackUrls[i].id,
            title: trackUrls[i].title,
            artist: trackUrls[i].singer,
            genre: trackUrls[i].genre,
            album: trackUrls[i].lyrics,
            displayDescription: trackUrls[i].filepath,
            duration: Duration(minutes: int.parse(trackUrls[i].duration)),
            artUri: Uri.parse(MyUrl.fullurl + trackUrls[i].image),
          ),
        ),
      );
      totalduration = totalduration + int.parse(trackUrls[i].duration);
    }
    setState(() {
      HomePageState.playlist = ConcatenatingAudioSource(children: playlist);
      totalDuration =
          Duration(seconds: totalduration, milliseconds: totalduration);
    });

    return playlist;
  }

  // bool play = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color.fromARGB(255, 16, 22, 42),
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      toolbarHeight: 70,
                      centerTitle: true,
                      // backgroundColor: Color.fromARGB(255, 8, 49, 212),
                      backgroundColor: Colors.cyan,
                      leading: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_sharp,
                            color: Colors.white,
                          )),
                      expandedHeight: 400.0,
                      pinned: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned(
                            child: FlexibleSpaceBar(
                              stretchModes: const <StretchMode>[
                                StretchMode.zoomBackground
                              ],
                              centerTitle: true,
                              titlePadding:
                                  const EdgeInsets.only(left: 60, bottom: 10),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Total Duration: $totalDuration',
                                        style: const TextStyle(fontSize: 8),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              background: CachedNetworkImage(
                                imageUrl: image,
                                // Your background image URL
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    globalclass.artist.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, int index) {
                                return Container(
                                  key: ValueKey(index),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 1),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        player.seek(Duration.zero,
                                            index: index);

                                        HomePageState.musicindex = index;

                                        HomePageState.songclass =
                                            globalclass.artist[index];
                                        HomePageState.listsong =
                                            globalclass.artist;
                                        HomePageState.id = int.parse(
                                            HomePageState.songclass.id);
                                        Get.back();
                                        Get.to(
                                            () => SongPage(
                                                HomePageState.playlist,
                                                HomePageState.musicindex,
                                                HomePageState.id,
                                                HomePageState.listsong),
                                            transition: Transition.downToUp);
                                      });
                                    },
                                    textColor: Colors.white,
                                    iconColor: Colors.white,
                                    title: Text(
                                      globalclass.artist[index].title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      globalclass.artist[index].singer,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: ClipOval(
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              MyUrl.fullurl + globalclass.artist[index].image,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: globalclass
                                  .artist.length, // Number of list items
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, index) => const Center(
                                      heightFactor: 10,
                                      child: Text(
                                        'No Music Found ',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                    ),
                                childCount: 1),
                          )
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
