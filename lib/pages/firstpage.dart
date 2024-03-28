import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:online_music_player/pages/loginpage.dart';
import 'package:online_music_player/pages/signuppage.dart';
import 'package:online_music_player/admin/admin_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  GlobalKey<FormState> form = GlobalKey();
  TextEditingController id = TextEditingController();
  bool isvisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/firstpage.png'),
              fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(.9),
                Colors.black.withOpacity(.4)
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: InkWell(
                    onDoubleTap: () {
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.scale,
                        dialogType: DialogType.info,
                        keyboardAware: true,
                        body: Form(
                          key: form,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  'Enter Admin Login Id',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Material(
                                  elevation: 0,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      return TextFormField(
                                        autofocus: true,
                                        minLines: 1,
                                        keyboardType: TextInputType.number,
                                        obscureText: isvisible,
                                        decoration: InputDecoration(
                                            suffixIcon: TextButton(
                                              child: isvisible
                                                  ? const Icon(
                                                      Icons
                                                          .visibility_off_rounded,
                                                      color: Colors.black,
                                                    )
                                                  : const Icon(
                                                      Icons.visibility,
                                                      color: Colors.black,
                                                    ),
                                              onPressed: () {
                                                setState(() {
                                                  isvisible = !isvisible;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 3)),
                                            hintText: 'Enter Id'),
                                        controller: id,
                                        validator: (value) {
                                          if (value == '') {
                                            return 'Id Required';
                                          } else {
                                            return null;
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        btnOkOnPress: () async {
                          if (form.currentState!.validate()) {
                            if (id.text == '0129') {
                              var sharedPref =
                                  await SharedPreferences.getInstance();
                              sharedPref.setString(
                                  "adminid", id.text.toString());
                              id.text = '';
                              Fluttertoast.showToast(
                                  msg: 'Successfully LoggedIn');
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminPanel()));
                            } else {
                              id.text = '';
                              Fluttertoast.showToast(msg: 'Wrong Id');
                            }
                          }
                        },
                        btnCancelOnPress: () {
                          id.text = '';
                        },
                      ).show();
                    },
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/splash.png"))),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: Text(
                    "All Your Music In One Place. Listen Anytime, Anywhere!",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 60,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginPage()));
                  },
                  color: const Color(0xff0095FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 60,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
                  },
                  color: const Color(0xff0095FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
