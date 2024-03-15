import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:online_music_player/main.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/models/userdetails.dart';
import 'package:online_music_player/pages/homepage.dart';
import 'package:online_music_player/pages/profilepage.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;
import 'package:online_music_player/pages/searchpage.dart';
import 'package:online_music_player/pages/songpage.dart';

class DashBoard extends StatefulWidget {
  User user;
  late Stream<bool> controller;
  DashBoard(this.user, this.controller, {super.key});

  @override
  State<DashBoard> createState() => DashBoardState(user, controller);
}

class DashBoardState extends State<DashBoard> {
  User user;
  late Stream<bool> controller;
  DashBoardState(this.user, this.controller);

  bool isplayervisible = false;

  late StreamSubscription<ConnectivityResult> subscription;
  String connectionStatus = 'Unknown';

  startMonitoringConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        if (result == ConnectivityResult.none) {
          connectionStatus = 'No Internet Connection';
          Fluttertoast.showToast(msg: connectionStatus);
        } else if (result == ConnectivityResult.wifi) {
          connectionStatus = 'Connected to Wi-Fi';
          Fluttertoast.showToast(msg: connectionStatus);
        } else if (result == ConnectivityResult.mobile) {
          connectionStatus = 'Connected to Mobile Data';
          Fluttertoast.showToast(msg: connectionStatus);
        }
      });
    });
    return connectionStatus;
  }

  void stopMonitoringConnectivity() {
    subscription.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      startMonitoringConnectivity();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // do something
      controller.listen((event) {
        refresh(event);
      });
    });
  }

  static int id = -1;

  refresh(bool a) {
    setState(() {
      isplayervisible = a;
      id = HomePageState.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomController = Get.put(NavigationController());

    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 157, 177),
          title: Obx(
            () => Text(
              "Hello, ${bottomController.appbartitle.value.toString()}",
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // actions: [
          //   Center(
          //     child: FittedBox(
          //       child: Center(
          //         child: Padding(
          //           padding: const EdgeInsets.all(20),
          //           child: Container(
          //             decoration: BoxDecoration(
          //                 color: Colors.black,
          //                 borderRadius: BorderRadius.circular(25)),
          //             child: TextButton.icon(
          //                 onPressed: () {
          //                   if (SongPageState.isPlayerInitialized == false) {
          //                     setState(() {
          //                       if (globalclass.controller1.isClosed) {
          //                         globalclass.controller1 =
          //                             StreamController<bool>.broadcast();
          //                       }
          //                     });
          //                     Navigator.of(context).push(MaterialPageRoute(
          //                         builder: (context) => OfflineMusic(
          //                             globalclass.controller1.stream)));
          //                   } else {
          //                     AwesomeDialog(
          //                       context: context,
          //                       animType: AnimType.bottomSlide,
          //                       dismissOnTouchOutside: false,
          //                       btnCancelColor: Colors.grey,
          //                       dialogType: DialogType.warning,
          //                       btnOkColor: Colors.red,
          //                       title: 'Alert Infomation',
          //                       desc:
          //                           'Your Online Music Streaming is On!\nDo You Want to Close the Online Music Streaming?',
          //                       btnOkOnPress: () {
          //                         setState(() {
          //                           player.stop();

          //                           SongPageState.isPlayerInitialized = false;
          //                           globalclass.controller.add(false);

          //                           if (globalclass.controller1.isClosed) {
          //                             globalclass.controller1 =
          //                                 StreamController<bool>.broadcast();
          //                           }
          //                         });
          //                         Navigator.of(context).push(MaterialPageRoute(
          //                             builder: (context) => OfflineMusic(
          //                                 globalclass.controller1.stream)));
          //                       },
          //                       btnCancelOnPress: () {},
          //                     ).show();
          //                   }
          //                 },
          //                 label: const Text(
          //                   "Offline Music",
          //                   style: TextStyle(
          //                       color: Colors.white,
          //                       fontWeight: FontWeight.normal),
          //                 ),
          //                 icon: const Icon(
          //                   Icons.music_note_rounded,
          //                   color: Colors.white,
          //                 )),
          //           ),
          //         ),
          //       ),
          //     ),
          //   )
          // ],
        ),
        body: Obx(() => bottomController.selectedIndex > 1
            ? ProfilePage(user)
            : bottomController.pages[bottomController.selectedIndex.value]),
        bottomNavigationBar: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: isplayervisible,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<SequenceState?>(
                        stream: player.sequenceStateStream,
                        builder: (context, snapshot) {
                          final state = snapshot.data;
                          final sequence = state?.sequence ?? [];

                          int index = state?.currentIndex != null
                              ? int.parse('${state?.currentIndex}')
                              : -1;

                          if (index == -1) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                isplayervisible = false;
                              });
                            });
                          }
                          return Container(
                              key: ValueKey(state?.currentIndex),
                              height: 70,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.00, -1.00),
                                  end: Alignment(0, 1),
                                  colors: [
                                    Color(0xFF065574),
                                    Color(0xFF074D67),
                                    Color(0xFF0A3E53),
                                    Color(0xFF0E242F),
                                    Color(0xFF111619)
                                  ],
                                ),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: ListTile(
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    Get.to(
                                        () => SongPage(
                                            HomePageState.playlist,
                                            HomePageState.musicindex,
                                            id,
                                            HomePageState.listsong),
                                        transition: Transition.downToUp);
                                  });
                                },
                                leading: CircleAvatar(
                                  radius: 30,
                                  child: CachedNetworkImage(
                                    imageUrl: sequence.isNotEmpty
                                        ? '${sequence[state!.currentIndex].tag.artUri}'
                                        : MyUrl.fullurl +
                                            HomePageState.listsong[0].image,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    imageBuilder: (context, imageProvider) {
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
                                title: SizedBox(
                                  width: 50,
                                  child: sequence.isNotEmpty
                                      ? Text(
                                          sequence[index].tag.title,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : const Text(
                                          'Title',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                ),
                                subtitle: SizedBox(
                                  width: 50,
                                  child: Text(
                                    sequence.isNotEmpty
                                        ? sequence[index].tag.artist
                                        : 'Artist',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: 170,
                                  child: Row(
                                    children: [
                                      StreamBuilder<SequenceState?>(
                                        stream: player.sequenceStateStream,
                                        builder: (context, snapshot) {
                                          return Flexible(
                                            child: IconButton(
                                                iconSize: 32.0,
                                                color: Colors.white,
                                                icon: player.hasPrevious
                                                    ? Visibility(
                                                        visible:
                                                            player.hasPrevious,
                                                        child: const Icon(Icons
                                                            .skip_previous_rounded))
                                                    : Visibility(
                                                        visible:
                                                            player.hasPrevious,
                                                        child: const Icon(Icons
                                                            .skip_previous_rounded)),
                                                onPressed: () {
                                                  player.hasPrevious
                                                      ? player.seekToPrevious()
                                                      : null;
                                                }),
                                          );
                                        },
                                      ),
                                      StreamBuilder<PlayerState>(
                                        stream: player.playerStateStream,
                                        builder: (context, snapshot) {
                                          final playerState = snapshot.data;
                                          final processingState =
                                              playerState?.processingState;
                                          final playing = playerState?.playing;
                                          if (processingState ==
                                                  ProcessingState.loading ||
                                              processingState ==
                                                  ProcessingState.buffering) {
                                            return Flexible(
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.all(8.0),
                                                width: 27.0,
                                                height: 27.0,
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                            );
                                          } else if (playing != true) {
                                            return Flexible(
                                              child: IconButton(
                                                  icon: const Icon(
                                                      Icons.play_arrow_rounded,
                                                      color: Colors.white),
                                                  iconSize: 32,
                                                  onPressed: () {
                                                    player.play();
                                                  }),
                                            );
                                          } else if (processingState !=
                                              ProcessingState.completed) {
                                            return Flexible(
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.pause_rounded,
                                                    color: Colors.white),
                                                iconSize: 32.0,
                                                onPressed: player.pause,
                                              ),
                                            );
                                          } else {
                                            return Flexible(
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.replay_rounded,
                                                    color: Colors.white),
                                                iconSize: 32.0,
                                                onPressed: () => player.seek(
                                                    Duration.zero,
                                                    index: player
                                                        .effectiveIndices!
                                                        .first),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      StreamBuilder<SequenceState?>(
                                        stream: player.sequenceStateStream,
                                        builder: (context, snapshot) {
                                          return Flexible(
                                            child: IconButton(
                                              iconSize: 32,
                                              color: Colors.white,
                                              icon: player.hasNext
                                                  ? Visibility(
                                                      visible: player.hasNext,
                                                      child: const Icon(Icons
                                                          .skip_next_rounded))
                                                  : Visibility(
                                                      visible: player.hasNext,
                                                      child: const Icon(Icons
                                                          .skip_next_rounded)),
                                              onPressed: () {
                                                player.hasNext
                                                    ? player.seekToNext()
                                                    : null;
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      Flexible(
                                        child: IconButton(
                                            onPressed: () {
                                              // SongPageState.beforeid = 0;
                                              // SongPageState.beforeindex = 0;
                                              player.stop();
                                              setState(() {
                                                globalclass.controller
                                                    .add(false);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              size: 32,
                                              color: Colors.white,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 157, 177),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.1),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8),
                    child: GNav(
                      rippleColor: Colors.grey[300]!,
                      hoverColor: Colors.grey[100]!,
                      gap: 8,
                      activeColor: Colors.white,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor: Colors.black,
                      color: Colors.black,
                      tabs: const [
                        GButton(
                          icon: Icons.home,
                          text: 'Home',
                        ),
                        GButton(
                          icon: Icons.search,
                          text: 'Search',
                        ),
                        GButton(
                          icon: Icons.person,
                          text: 'Profile',
                        ),
                      ],
                      selectedIndex: bottomController.selectedIndex.value,
                      onTabChange: (index) =>
                          bottomController.selectedIndex.value = index,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final Rx<String> appbartitle = ''.obs;
  List<Widget> pages = const [HomePage(), SearchPage()];
}
