import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/pages/loginpage.dart';
import 'package:online_music_player/models/store_email.dart';
import 'package:online_music_player/pages/loadingdialog.dart';

// ignore: must_be_immutable
class PasswordSet extends StatefulWidget {
  Email email;
  PasswordSet(this.email);

  @override
  State<PasswordSet> createState() => _PasswordSetState(email);
}

class _PasswordSetState extends State<PasswordSet> {
  Email email;
  _PasswordSetState(this.email);
  bool type = true;
  bool type1 = true;

  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey();
  Future<void> updatePassword(String pass1, String pass2) async {
    Map data = {'email': email.email, 'password': pass1};
    if (formkey.currentState!.validate()) {
      if (pass1 == pass2) {
        showDialog(
            context: context,
            builder: (context) {
              return const LoadingDialog();
            });
        try {
          var res = await http.post(
              Uri.http(MyUrl.mainurl, MyUrl.suburl + "change_password.php"),
              body: data);

          var jsondata = jsonDecode(res.body);
          if (jsondata['status'] == true) {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()));
            Fluttertoast.showToast(
              msg: jsondata['msg'],
            );
          } else {
            Navigator.of(context).pop();
            Fluttertoast.showToast(
              msg: jsondata['msg'],
            );
          }
        } catch (e) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: e.toString());
        }
      } else {
        Fluttertoast.showToast(msg: 'Password Must be same');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            color: Colors.transparent,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.info_circle,
                                      color: Colors.blue,
                                      size: 60,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Set Password',
                                      textScaleFactor: 2,
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Enter a new password \nto reset your old password',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.blueGrey),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Form(
                                      key: formkey,
                                      child: Flexible(
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              child: TextFormField(
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0)),
                                                decoration: InputDecoration(
                                                  errorStyle: const TextStyle(
                                                      color: Colors.blue),
                                                  hintText: email.email,
                                                  fillColor: Colors.grey[150],
                                                  filled: true,
                                                  enabled: false,
                                                  prefixIcon: const Icon(
                                                      CupertinoIcons.mail),
                                                  suffixIcon: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.greenAccent,
                                                  ),
                                                  prefixIconColor: Colors.cyan,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          top: 0, left: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                              ),
                                            ),
                                            Container(
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        child: Text(
                                                      'Email Verified',
                                                      style: TextStyle(
                                                          color: Colors.cyan),
                                                    )),
                                                    SizedBox(
                                                      child: Icon(
                                                        Icons.check,
                                                        color:
                                                            Colors.greenAccent,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              child: TextFormField(
                                                controller: t2,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "New Password Required";
                                                  } else if (t2.text.length <=
                                                      7) {
                                                    return 'Password must be atleast 8 digit';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                obscureText: type,
                                                decoration: InputDecoration(
                                                  labelText: 'New Password',
                                                  hintText: 'New Password',
                                                  prefixIconColor: Colors.cyan,
                                                  prefixIcon: const Icon(
                                                      CupertinoIcons.lock),
                                                  suffixIcon: TextButton(
                                                    child: type
                                                        ? const Icon(
                                                            Icons
                                                                .visibility_off,
                                                            color: Colors.black,
                                                          )
                                                        : const Icon(
                                                            Icons.visibility,
                                                            color: Colors.black,
                                                          ),
                                                    onPressed: () {
                                                      setState(() {
                                                        type = !type;
                                                      });
                                                    },
                                                  ),
                                                  fillColor: Colors.grey[150],
                                                  filled: true,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          top: 0, left: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 25),
                                              child: TextFormField(
                                                controller: t3,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please re enter your Password";
                                                  } else if (t2.text !=
                                                      t3.text) {
                                                    return "Password Do not match";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                obscureText: type1,
                                                decoration: InputDecoration(
                                                  labelText: 'Confirm Password',
                                                  hintText: 'Confirm Password',
                                                  prefixIconColor: Colors.cyan,
                                                  prefixIcon: const Icon(
                                                      CupertinoIcons.lock),
                                                  suffixIcon: TextButton(
                                                    child: type1
                                                        ? const Icon(Icons
                                                            .visibility_off,color: Colors.black,)
                                                        : const Icon(
                                                            Icons.visibility,color: Colors.black,
                                                          ),
                                                    onPressed: () {
                                                      setState(() {
                                                        type1 = !type1;
                                                      });
                                                    },
                                                  ),
                                                  fillColor: Colors.grey[150],
                                                  filled: true,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          top: 0,
                                                          left: 10,
                                                          bottom: 0),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 30, bottom: 10),
                                              width: 200,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  updatePassword(
                                                      t2.text, t3.text);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20),
                                                  child: Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (states) => Colors.blue,
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        ),
      ),
    );
  }
}
