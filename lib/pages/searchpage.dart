import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:online_music_player/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_music_player/pages/voice.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/pages/homepage.dart';
import 'package:online_music_player/pages/songpage.dart';
import 'package:online_music_player/models/song_fetch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  List<Song> trackUrls = [];

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
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
    setState(() {});
    return playlist;
  }

  void _filterItems(String query) {
    globalclass.search.clear();
    query = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        globalclass.search.clear();
      } else {
        globalclass.search = globalclass.songs
            .where((item) =>
                item.title.toLowerCase().contains(query) ||
                item.genre.toLowerCase().contains(query) ||
                item.lyrics.toLowerCase().contains(query) ||
                item.singer.toLowerCase().contains(query))
            .toList();
        // visible = false;
      }
    });
  }

  // static bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        extendBody: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "Search",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 320,
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: TextFormField(
                          onChanged: (query) {
                            _filterItems(query.trim());
                          },
                          decoration: InputDecoration(
                            hintText: 'What do you want to listen?',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(onPressed: (){
                              Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => const Voice()))
                                      .then((value) {
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  });
                            }, icon: const Icon(Icons.mic_rounded),color: Colors.black,),
                            fillColor: Colors.grey[300],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: globalclass.search.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: globalclass.search.length,
                            physics: const ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: 70,
                                child: ListTile(
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        globalclass.search.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    globalclass.search[index].title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    globalclass.search[index].singer,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 35,
                                    child: CachedNetworkImage(
                                      imageUrl: MyUrl.fullurl +
                                          globalclass.search[index].image,
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
                                              image: DecorationImage(
                                                  image: imageProvider)),
                                        );
                                      },
                                    ),
                                  ),
                                  onTap: () {
                                    SongPageState.beforeid = 0;
                                    setState(() {
                                      // visible = true;
                                      player.seek(Duration.zero, index: index);
                                      HomePageState.playlist =
                                          ConcatenatingAudioSource(
                                              children: buildPlaylist(
                                                  globalclass.search));
                                      HomePageState.musicindex = index;
                                      HomePageState.songclass =
                                          globalclass.search[index];
                                      HomePageState.listsong =
                                          globalclass.search;
                                      HomePageState.id =
                                          int.parse(HomePageState.songclass.id);
                                      // HomePageState.img =
                                      //     '${MyUrl.fullurl}${HomePageState.songclass.image}';
                                      // HomePageState.title =
                                      //     globalclass.search[index].title;
                                      // HomePageState.subtitle =
                                      //     '${globalclass.search[index].singer}';
                                      // globalclass.controller.add(true);

                                      Get.to(
                                          () => SongPage(
                                              HomePageState.playlist,
                                              HomePageState.musicindex,
                                              HomePageState.id,
                                              HomePageState.listsong),
                                          transition: Transition.downToUp);
                                    });
                                  },
                                ),
                              );
                            },
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No Result Found',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 25),
                                  ),
                                ],
                              )
                            ],
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
