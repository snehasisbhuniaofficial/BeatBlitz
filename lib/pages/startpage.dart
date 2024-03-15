import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:online_music_player/admin/admin_panel.dart';
import 'package:online_music_player/main.dart';
import 'package:online_music_player/models/userdetails.dart';
import 'package:online_music_player/pages/dashboard.dart';
import 'package:online_music_player/pages/firstpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  static const String KEYLOGIN = "login";

  @override
  void initState() {
    super.initState();
    if (globalclass.isPlayer == false) {
      player = AudioPlayer();
      globalclass.isPlayer = true;
    }
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/music.png'),
                  height: 250,
                  width: 250,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Developed By Snehasis",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    final bottomController = Get.put(NavigationController());
    var isLoggedIn = sharedPref.getBool(KEYLOGIN);

    String id = sharedPref.getString("id") ?? "";
    String name = sharedPref.getString("name") ?? "";
    String phone = sharedPref.getString("phone") ?? "";
    String email = sharedPref.getString("email") ?? "";
    String image = sharedPref.getString("image") ?? "";

    bottomController.appbartitle.value = name.toString();

    String adminid = sharedPref.getString("adminid") ?? "";

    Timer(const Duration(seconds: 2), () {
      if (isLoggedIn != null) {
        if (isLoggedIn) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashBoard(
                    User(id, name, phone, email, image),
                    globalclass.controller.stream),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FirstPage(),
              ));
        }
      } else if (adminid != '') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminPanel(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const FirstPage(),
            ));
      }
    });
  }
}
