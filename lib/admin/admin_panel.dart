import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/pages/loadingdialog.dart';
import 'package:online_music_player/pages/startpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  GlobalKey<FormState> form = GlobalKey();
  TextEditingController title = TextEditingController();
  TextEditingController singer = TextEditingController();
  TextEditingController genre = TextEditingController();
  TextEditingController duration = TextEditingController();
  TextEditingController fileformat = TextEditingController();
  TextEditingController lyrics = TextEditingController();
  TextEditingController songfile = TextEditingController();
  TextEditingController image = TextEditingController();

  File? pickedImage;
  File? pickedFile;

  pickImage() async {
    try {
      FilePickerResult? photo = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
      if (photo == null) return;
      File tempImage = File(photo.files.single.path!);
      setState(() {
        pickedImage = tempImage;
        var pickname = photo.files.single.name;
        image.text = pickname.toString();
      });
      Get.back();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'flac'],
      );
      if (result == null) return;
      File tempFile = File(result.files.single.path!);
      setState(() {
        pickedFile = tempFile;
        var pickName = result.files.single.name;
        songfile.text = pickName.toString();
      });
      Get.back();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future upload(String title, String singer, String genre, String duration,
      String fileformat, File? filepath, File? image, String lyrics) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoadingDialog();
      },
    );
    try {
      var request = http.MultipartRequest(
          "POST", Uri.parse("${MyUrl.fullurl}song_upload.php"));

      request.fields["title"] = title;
      request.fields["singer"] = singer;
      request.fields["genre"] = genre;
      request.fields["duration"] = duration;
      request.fields["file_format"] = fileformat;

      request.files.add(await http.MultipartFile.fromBytes(
          "file_path", filepath!.readAsBytesSync(),
          filename: filepath.path.split("/").last));

      request.files.add(await http.MultipartFile.fromBytes(
          "image", image!.readAsBytesSync(),
          filename: image.path.split("/").last));

      request.fields['lyrics'] = lyrics;

      var response = await request.send();
      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(jsondata['msg'].toString()),
            );
          });

      if (jsondata['status'] == true) {
        // ignore: use_build_context_synchronously
        AwesomeDialog(
          context: context,
          animType: AnimType.bottomSlide,
          dismissOnTouchOutside: true,
          dialogType: DialogType.success,
          title: 'Music Upload',
          desc: 'Successfully Uploded',
          btnOkOnPress: () {},
        ).show();
      } else {
        Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: jsondata['msg'],
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        gravity: ToastGravity.CENTER,
        msg: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.cyan,
            centerTitle: true,
            title: Text(
              'Upload Song'.toUpperCase(),
              style: const TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    var sharedPref = await SharedPreferences.getInstance();
                    sharedPref.clear();
                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StartPage()),
                        (Route<dynamic> route) => false);
                    Fluttertoast.showToast(msg: 'Logout Successful');
                  },
                  icon: const Icon(Icons.logout)),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Form(
                key: form,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 30, right: 30, bottom: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        child: TextFormField(
                          validator: (value) {
                            if (title.text.isEmpty) {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.text,
                          controller: title,
                          decoration: InputDecoration(
                              hintText: 'Title',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        child: TextFormField(
                          validator: (value) {
                            if (singer.text == '') {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.text,
                          controller: singer,
                          decoration: InputDecoration(
                              hintText: 'Singer',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          validator: (value) {
                            if (genre.text == '') {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.text,
                          controller: genre,
                          decoration: InputDecoration(
                              hintText: 'Genre',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          validator: (value) {
                            if (duration.text == '') {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          controller: duration,
                          decoration: InputDecoration(
                              hintText: 'Duration',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          validator: (value) {
                            if (fileformat.text == '') {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: fileformat,
                          decoration: InputDecoration(
                              hintText: 'File Format',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          validator: (value) {
                            if (value == '') {
                              return 'Required';
                            }
                          },
                          controller: image,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    pickImage();
                                  },
                                  icon: const Icon(Icons.image)),
                              hintText: 'Audio Image',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          maxLines: null,
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (lyrics.text == '') {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: lyrics,
                          decoration: InputDecoration(
                              hintText: 'Lyrics',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          validator: (value) {
                            if (value == '') {
                              return 'Required';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: songfile,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    pickFile();
                                  },
                                  icon: const Icon(Icons.file_upload)),
                              hintText: 'Audio File',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 10))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () {
                              if (form.currentState!.validate()) {
                                upload(
                                    title.text,
                                    singer.text,
                                    genre.text,
                                    duration.text.toString(),
                                    fileformat.text,
                                    pickedFile,
                                    pickedImage,
                                    lyrics.text);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.blue),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Upload',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
