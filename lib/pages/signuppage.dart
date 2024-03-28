import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_music_player/models/myurl.dart';
import 'package:online_music_player/pages/dashboard.dart';
import 'package:online_music_player/pages/loginpage.dart';
import 'package:online_music_player/pages/startpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:online_music_player/models/userdetails.dart';
import 'package:online_music_player/pages/loadingdialog.dart';
import 'package:online_music_player/models/globalclass.dart' as globalclass;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> formkey = GlobalKey();
  bool isvisible = false;
  bool type = true;
  bool tp = true;
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmpassword = TextEditingController();
  final bottomController = Get.put(NavigationController());

  InputDecoration style = InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your Email',
    fillColor: Colors.grey[150],
    filled: true,
    prefixIcon: const Icon(Icons.email),
    prefixIconColor: Colors.black,
    contentPadding: const EdgeInsets.only(top: 0, left: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(
          color: Color.fromARGB(
            255,
            5,
            127,
            192,
          ),
          width: 2),
    ),
  );
  Future<void> signupStatus(
      String name, String phone, String email, String password) async {
    Map data = {
      "name": name,
      "phone": phone,
      "email": email,
      "password": password
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingDialog();
        });

    try {
      var response = await http.post(
          Uri.http(MyUrl.mainurl, MyUrl.suburl + "user_signup.php"),
          body: data);

      var jsondata = jsonDecode(response.body);
      if (jsondata["status"] == true) {
        Navigator.pop(context);

        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(StartPageState.KEYLOGIN, true);

        sharedPref.setString("id", jsondata["id"].toString());
        sharedPref.setString("name", jsondata["name"].toString());
        sharedPref.setString("phone", jsondata["phone"].toString());
        sharedPref.setString("email", jsondata["email"].toString());
        sharedPref.setString("image", jsondata["image"].toString());
        User user = User(
            jsondata["id"].toString(),
            jsondata["name"].toString(),
            jsondata["phone"].toString(),
            jsondata["email"].toString(),
            jsondata["image"].toString());

        bottomController.appbartitle.value = jsondata["name"].toString();

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                DashBoard(user, globalclass.controller.stream)));
        Fluttertoast.showToast(
          msg: jsondata['msg'],
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
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
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        "Register your account",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      controller: _name,
                      keyboardType: TextInputType.name,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "Enter your Full Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28)),
                        prefixIcon: Icon(CupertinoIcons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name Required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "Phone No",
                        hintText: "Enter your Phone No",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28)),
                        prefixIcon: Icon(CupertinoIcons.phone),
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
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28)),
                        prefixIcon: Icon(CupertinoIcons.mail),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email Required";
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$')
                            .hasMatch(value)) {
                          return "Please enter valid email";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: type,
                      decoration: InputDecoration(
                        labelText: "Create Password",
                        hintText: "Create a strong password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28)),
                        prefixIcon: const Icon(CupertinoIcons.lock),
                        suffixIcon: TextButton(
                          child: type
                              ? const Icon(Icons.visibility_off_rounded,
                                  color: Colors.black)
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
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password Required";
                        } else if (_password.text.length <= 7) {
                          return 'Password must be atleast 8 Characters';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _confirmpassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: tp,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "Confirm your password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28)),
                        prefixIcon: Icon(CupertinoIcons.lock),
                        suffixIcon: TextButton(
                          child: tp
                              ? const Icon(Icons.visibility_off_rounded,
                                  color: Colors.black)
                              : const Icon(
                                  Icons.visibility,
                                  color: Colors.black,
                                ),
                          onPressed: () {
                            setState(() {
                              tp = !tp;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please re enter your Password";
                        } else if (_password.text != _confirmpassword.text) {
                          return "Password Do not match";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            signupStatus(_name.text, _phone.text, _email.text,
                                _password.text);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please Enter your all Details");
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
                            'Register',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            )),
                      ],
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
