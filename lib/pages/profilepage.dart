import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_music_player/main.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/models/userdetails.dart';
import 'package:online_music_player/pages/dashboard.dart';
import 'package:online_music_player/pages/loadingdialog.dart';
import 'package:online_music_player/pages/password/verify.dart';
import 'package:http/http.dart' as http;
import 'package:online_music_player/pages/songpage.dart';
import 'package:online_music_player/pages/startpage.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage(this.user);

  @override
  State<ProfilePage> createState() => _ProfilePageState(user);
}

class _ProfilePageState extends State<ProfilePage> {
  String i = '';

  GlobalKey<FormState> namekey = GlobalKey();
  GlobalKey<FormState> phonekey = GlobalKey();
  GlobalKey<FormState> emailkey = GlobalKey();

  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();

  final bottomController = Get.put(NavigationController());

  User user;
  _ProfilePageState(this.user);
  File? pickedImage;
  Future pickImage(ImageSource imageType) async {
    try {
      final photo =
          await ImagePicker().pickImage(source: imageType, imageQuality: 50);
      if (photo != null) {
        final tempImage = File(photo.path);
        setState(() {
          pickedImage = tempImage;
        });
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future createprofile(File photo, String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoadingDialog();
      },
    );

    try {
      var request = http.MultipartRequest(
          "POST", Uri.parse(MyUrl.fullurl + "image_update.php"));
      request.files.add(await http.MultipartFile.fromBytes(
          'image', photo.readAsBytesSync(),
          filename: photo.path.split("/").last));
      request.fields['id'] = id;

      var response = await request.send();

      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);
      if (jsondata['status'] == 'true') {
        Navigator.pop(context);
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setString("image", jsondata["imgtitle"]);
        user.image = jsondata["imgtitle"];
        setState(() {
          i = jsondata["imgtitle"];
        });
        Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: jsondata['msg'],
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: jsondata['msg'],
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        gravity: ToastGravity.CENTER,
        msg: e.toString(),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    x().whenComplete(() {
      setState(() {});
    });
    super.initState();
  }

  Future x() async {
    var sharedPref = await SharedPreferences.getInstance();
    i = sharedPref.getString("image") ?? '';
  }

  Future<void> updatename(String name) async {
    Map data = {'id': user.id, 'name': name};
    var sharedPref = await SharedPreferences.getInstance();
    if (namekey.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return const LoadingDialog();
          });
      try {
        var res = await http.post(
            Uri.http(MyUrl.mainurl, MyUrl.suburl + "name_update.php"),
            body: data);

        var jsondata = jsonDecode(res.body);
        if (jsondata['status'] == true) {
          Navigator.of(context).pop();
          Navigator.pop(context);
          setState(() {
            sharedPref.setString("name", jsondata["name"]);
            user.name = jsondata["name"];
          });
          bottomController.appbartitle.value = jsondata["name"].toString();
          Fluttertoast.showToast(
            msg: jsondata['msg'],
          );
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            msg: jsondata['msg'],
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> updatephone(String phone) async {
    Map data = {'id': user.id, 'phone': phone};
    var sharedPref = await SharedPreferences.getInstance();
    if (phonekey.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return const LoadingDialog();
          });
      try {
        var res = await http.post(
            Uri.http(MyUrl.mainurl, MyUrl.suburl + "phone_update.php"),
            body: data);

        var jsondata = jsonDecode(res.body);
        if (jsondata['status'] == true) {
          Navigator.of(context).pop();
          Navigator.pop(context);
          setState(() {
            sharedPref.setString("phone", jsondata["phone"]);
            user.phone = jsondata["phone"];
          });
          Fluttertoast.showToast(
            msg: jsondata['msg'],
          );
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            msg: jsondata['msg'],
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> updateemail(String email) async {
    Map data = {'id': user.id, 'email': email};
    var sharedPref = await SharedPreferences.getInstance();
    if (emailkey.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return const LoadingDialog();
          });
      try {
        var res = await http.post(
            Uri.http(MyUrl.mainurl, MyUrl.suburl + "email_update.php"),
            body: data);

        var jsondata = jsonDecode(res.body);
        if (jsondata['status'] == true) {
          Navigator.of(context).pop();
          Navigator.pop(context);
          setState(() {
            sharedPref.setString("email", jsondata["email"]);
            user.email = jsondata["email"];
          });
          Fluttertoast.showToast(
            msg: jsondata['msg'],
          );
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            msg: jsondata['msg'],
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Widget imageShow(image) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: CircleAvatar(
              backgroundColor: Colors.transparent,
              maxRadius: 150,
              foregroundImage: CachedNetworkImageProvider(image)),
        ),
      ),
    );
  }

  Future<void> showImageOptions() async {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.remove_red_eye_rounded,
                color: Colors.black,
              ),
              title: const Text(
                'View Photo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) {
                      return imageShow(
                          MyUrl.fullurl + MyUrl.imageurl + user.image);
                    });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.black,
                size: 25,
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera).whenComplete(
                  () {
                    if (pickedImage != null) {
                      createprofile(pickedImage!, user.id);
                    }
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.blue,
                size: 25,
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery).whenComplete(
                  () {
                    if (pickedImage != null) {
                      createprofile(pickedImage!, user.id);
                    }
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.close,
                color: Colors.red,
                size: 25,
              ),
              title: const Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Profile Information",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            showImageOptions();
                          },
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey,
                            child: pickedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      pickedImage!,
                                      height: 135,
                                      width: 135,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: MyUrl.fullurl +
                                          MyUrl.imageurl +
                                          user.image,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      imageBuilder: (context, imageProvider) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                image: DecorationImage(
                                                    image: imageProvider)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 10,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                            child: InkWell(
                              onTap: () {
                                showImageOptions();
                              },
                              child: const Icon(
                                CupertinoIcons.camera_circle_fill,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              color: Colors.deepOrange.withOpacity(.2),
                              spreadRadius: 2,
                              blurRadius: 10)
                        ]),
                    child: ListTile(
                      title: const Text('Name'),
                      subtitle: Text(user.name),
                      leading: const Icon(CupertinoIcons.person),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _name.text = user.name;
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: false,
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            pageBuilder: (context, animation1, animation2) {
                              return Container();
                            },
                            transitionBuilder: (context, a1, a2, Widget) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(a1),
                                child: FadeTransition(
                                  opacity: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(a1),
                                  child: AlertDialog(
                                      shape: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none),
                                      content: Form(
                                        key: namekey,
                                        child: TextFormField(
                                          controller: _name,
                                          keyboardType: TextInputType.name,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: const InputDecoration(
                                            labelText: "Name",
                                            hintText: "Enter your Full Name",
                                            prefixIcon:
                                                Icon(CupertinoIcons.person),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Name Required";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 15),
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              if (namekey.currentState!
                                                  .validate()) {
                                                updatename(_name.text);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please Enter Your Name");
                                              }
                                            },
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ))
                                      ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      tileColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              color: Colors.deepOrange.withOpacity(.2),
                              spreadRadius: 2,
                              blurRadius: 10)
                        ]),
                    child: ListTile(
                      title: Text('Phone'),
                      subtitle: Text(user.phone),
                      leading: Icon(CupertinoIcons.phone),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _phone.text = user.phone;
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: false,
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            pageBuilder: (context, animation1, animation2) {
                              return Container();
                            },
                            transitionBuilder: (context, a1, a2, Widget) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(a1),
                                child: FadeTransition(
                                  opacity: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(a1),
                                  child: AlertDialog(
                                      shape: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none),
                                      content: Form(
                                        key: phonekey,
                                        child: TextFormField(
                                          controller: _phone,
                                          keyboardType: TextInputType.phone,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            labelText: "Phone No",
                                            hintText: "Enter your Phone Number",
                                            prefixIcon:
                                                Icon(CupertinoIcons.phone),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Phone no Required";
                                            } else if (value.length < 10) {
                                              return "Please enter valid phone";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 15),
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              if (phonekey.currentState!
                                                  .validate()) {
                                                updatephone(_phone.text);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please Enter Your Phone Number");
                                              }
                                            },
                                            child: Text(
                                              "Save",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ))
                                      ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      tileColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              color: Colors.deepOrange.withOpacity(.2),
                              spreadRadius: 2,
                              blurRadius: 10)
                        ]),
                    child: ListTile(
                      title: Text('Email'),
                      subtitle: Text(user.email),
                      leading: Icon(CupertinoIcons.mail),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _email.text = user.email;
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: false,
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            pageBuilder: (context, animation1, animation2) {
                              return Container();
                            },
                            transitionBuilder: (context, a1, a2, Widget) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(a1),
                                child: FadeTransition(
                                  opacity: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(a1),
                                  child: AlertDialog(
                                      shape: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none),
                                      content: Form(
                                        key: emailkey,
                                        child: TextFormField(
                                          controller: _email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            labelText: "Email",
                                            hintText:
                                                "Enter your Email Address",
                                            prefixIcon:
                                                Icon(CupertinoIcons.mail),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Email Required";
                                            } else if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$')
                                                .hasMatch(value)) {
                                              return "Please enter valid email";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 15),
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              if (emailkey.currentState!
                                                  .validate()) {
                                                updateemail(_email.text);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please Enter Your Email Id");
                                              }
                                            },
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ))
                                      ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      tileColor: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: '',
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              pageBuilder: (context, animation1, animation2) {
                                return Container();
                              },
                              transitionBuilder: (context, a1, a2, Widget) {
                                return ScaleTransition(
                                  scale: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(a1),
                                  child: FadeTransition(
                                    opacity: Tween<double>(begin: 0.5, end: 1.0)
                                        .animate(a1),
                                    child: AlertDialog(
                                      title: const Text('Are You Sure?'),
                                      content: const Text(
                                          'Do you want to change your password?'),
                                      shape: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'No',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            SongPageState.isPlayerInitialized =
                                                false;
                                            SongPageState.beforeid = 0;
                                            SongPageState.beforeindex = 0;
                                            player.dispose();
                                            globalclass.isPlayer = false;
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtpVerify(user)));
                                          },
                                          child: const Text(
                                            "Yes",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Change password?",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: '',
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (context, animation1, animation2) {
                            return Container();
                          },
                          transitionBuilder: (context, a1, a2, Widget) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 1.0)
                                  .animate(a1),
                              child: FadeTransition(
                                opacity: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(a1),
                                child: AlertDialog(
                                  title: const Text('Are You Sure?'),
                                  content: const Text('Do you want to logout?'),
                                  shape: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'No',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        SongPageState.isPlayerInitialized =
                                            false;
                                        SongPageState.beforeid = 0;
                                        SongPageState.beforeindex = 0;
                                        player.dispose();
                                        globalclass.isPlayer = false;
                                        var sharedPref = await SharedPreferences
                                            .getInstance();
                                        sharedPref.clear();
                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const StartPage()),
                                            (Route<dynamic> route) => false);
                                        Fluttertoast.showToast(
                                            msg: 'Logout Successful');
                                      },
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.red),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
