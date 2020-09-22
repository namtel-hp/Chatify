import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/HomeScreen.dart';
import 'package:flutter_auth/Screens/Login/login_screen.dart';
import 'package:flutter_auth/Screens/Signup/components/background.dart';
import 'package:flutter_auth/Screens/Signup/components/or_divider.dart';
import 'package:flutter_auth/Screens/Signup/components/social_icon.dart';
import 'package:flutter_auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_inputname_field.dart';
import 'package:flutter_auth/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  static const kPrimaryColor = Color(0xFF6F35A5);
  TextEditingController nameEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  SharedPreferences preferences;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedin = false;
  bool isloading = false;

  void _registeruser() async {
    preferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;

    await _auth
        .createUserWithEmailAndPassword(
            email: emailEditingController.text.trim(),
            password: passwordEditingController.text.trim())
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((error) {
      print(error);
    });

    if (firebaseUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection("Users")
          .where("uid", isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        Firestore.instance
            .collection("Users")
            .document(firebaseUser.uid)
            .setData({
          "uid": firebaseUser.uid,
          "email": firebaseUser.email,
          "name": nameEditingController.text.trim(),
          "photo": firebaseUser.photoUrl,
        });
        FirebaseUser currentuser = firebaseUser;
        await preferences.setString("uid", currentuser.uid);
        await preferences.setString("name", currentuser.displayName);
        await preferences.setString("photo", currentuser.photoUrl);
      } else {
        FirebaseUser currentuser = firebaseUser;
        await preferences.setString("uid", documents[0]["uid"]);
        await preferences.setString("name", documents[0]["name"]);
        await preferences.setString("photo", documents[0]["photo"]);
      }
      Navigator.pop(context);
      print(firebaseUser);
      Route route = MaterialPageRoute(builder: (c) => HomeScreen());
      Navigator.pushReplacement(context, route);
    } else {
      Fluttertoast.showToast(msg: "Sign in Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            TextFormField(
              controller: nameEditingController,
              validator: (val) {
                return val.isEmpty || val.length < 3
                    ? "Enter Username 3+ characters"
                    : null;
              },
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: kPrimaryColor,
                ),
                hintText: "Your Name",
                border: InputBorder.none,
              ),
            ),
            TextFormField(
              controller: emailEditingController,
              validator: (emailValue) {
                if (emailValue.isEmpty) {
                  return 'This field is mandatory';
                }

                String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                    "\\@" +
                    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                    "(" +
                    "\\." +
                    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                    ")+";
                RegExp regExp = new RegExp(p);

                if (regExp.hasMatch(emailValue)) {
                  // So, the email is valid
                  return null;
                }

                return 'This is not a valid email';
              },
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: kPrimaryColor,
                ),
                hintText: "Your Email",
                border: InputBorder.none,
              ),
            ),
            TextFormField(
              controller: passwordEditingController,
              obscureText: true,
              validator: (pwValue) {
                if (pwValue.isEmpty) {
                  return 'This field is mandatory';
                }
                if (pwValue.length < 6) {
                  return 'Password must be at least 6 characters';
                }

                return null;
              },
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Password",
                icon: Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                ),
                suffixIcon: Icon(
                  Icons.visibility,
                  color: kPrimaryColor,
                ),
                border: InputBorder.none,
              ),
            ),
            RoundedButton(
              text: "SIGNUP",
              press: () {
                _registeruser();
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/twitter.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}