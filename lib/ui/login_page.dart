import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobilefinal2/db/user_db.dart';
import 'package:mobilefinal2/utils/current_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

SharedPreferences sharedPreferences;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  UserUtils user = UserUtils();
  final userid = TextEditingController();
  final password = TextEditingController();
  bool isValid = false;
  int formState = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<String> readContent() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If there is an error reading, return a default String
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      checkLogin(String userIdCheck) async {
        await user.open("user.db");
        Future<List<User>> allUser = user.getAllUser();
        Future isUserValid(String userid) async {
          var userList = await allUser;
          for (var i = 0; i < userList.length; i++) {
            if (userid == userList[i].userid) {
              // Set user
              CurrentUser.id = userList[i].id;
              CurrentUser.userId = userList[i].userid;
              CurrentUser.name = userList[i].name;
              CurrentUser.age = userList[i].age;
              CurrentUser.password = userList[i].password;
              CurrentUser.quote = await readContent();

              this.isValid = true;

              // Set SharedPreferences
              sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setString("userId", userList[i].userid);
              sharedPreferences.setString("name", userList[i].name);
              return Navigator.pushReplacementNamed(context, '/home');
            }
          }
        }

        isUserValid(userIdCheck);
      }

      getCredential() async {
        sharedPreferences = await SharedPreferences.getInstance();
        String username = sharedPreferences.getString('userId');
        if (username != "" && username != null) {
          checkLogin(username);
        }
      }

      getCredential();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 30, 0),
          children: <Widget>[
            Image.asset(
              "assets/logo.jpg",
              width: 200,
              height: 200,
            ),
            TextFormField(
                decoration: InputDecoration(
                  labelText: "UserId",
                  icon: Icon(Icons.account_box, size: 40, color: Colors.grey),
                ),
                controller: userid,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isNotEmpty) {
                    this.formState += 1;
                  }
                }),
            TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                  icon: Icon(Icons.lock, size: 40, color: Colors.grey),
                ),
                controller: password,
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isNotEmpty) {
                    this.formState += 1;
                  }
                }),
            Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 10)),
            RaisedButton(
              child: Text("Login"),
              onPressed: () async {
                _formkey.currentState.validate();
                await user.open("user.db");
                Future<List<User>> allUser = user.getAllUser();

                Future isUserValid(String userid, String password) async {
                  var userList = await allUser;
                  for (var i = 0; i < userList.length; i++) {
                    if (userid == userList[i].userid &&
                        password == userList[i].password) {
                      CurrentUser.id = userList[i].id;
                      CurrentUser.userId = userList[i].userid;
                      CurrentUser.name = userList[i].name;
                      CurrentUser.age = userList[i].age;
                      CurrentUser.password = userList[i].password;
                      CurrentUser.quote = await readContent();
                      this.isValid = true;
                      sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString(
                          "userId", userList[i].userid);
                      sharedPreferences.setString(
                          "name", userList[i].name);
                      break;
                    }
                  }
                }

                if (this.formState != 2) {
                  Toast.show("Please fill out this form", context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  this.formState = 0;
                } else {
                  this.formState = 0;
                  await isUserValid(userid.text, password.text);
                  if (!this.isValid) {
                    Toast.show("Invalid user or password", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                    userid.text = "";
                    password.text = "";
                  }
                }
              },
            ),
            FlatButton(
              child: Container(
                child: Text("Register New User", textAlign: TextAlign.right),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              padding: EdgeInsets.only(left: 180.0),
            ),
          ],
        ),
      ),
    );
  }
}
