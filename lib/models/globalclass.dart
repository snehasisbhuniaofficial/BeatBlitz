library ONLINE_MUSIC_PLAYER.globalclass;

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:online_music_player/models/song_fetch.dart';

List<Song> songs = [];
List<Song> search = [];
List<Song> hindi = [];
List<Song> bengali = [];
List<Song> artist = [];
bool isPlayer = false;

StreamController<bool> controller = StreamController.broadcast();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();