import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserAuth {
  static UserModel user = UserModel();

  Future<bool> isUserLogedIn() async {
    await getUserAuth();
    if (user.userId != null) {
      return true;
    }
    return false;
  }

  Future<void> saveUserAuth(UserModel userModel) async {
    user = userModel;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAuth', jsonEncode(userModel.toJson()));
  }

  static Future<void> getUserAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userAuth') == true) {
      Map<String, dynamic> authUser = jsonDecode(prefs.getString('userAuth')!);
      user = UserModel.fromJson(authUser);
    }
  }

  static Future<void> clearUserAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = UserModel();
    prefs.clear();
  }
}

class UserModel {
  String? userEmail;
  String? userId;

  UserModel({this.userEmail, this.userId});

  UserModel.fromJson(Map<String, dynamic> json) {
    userEmail = json["userEmail"];
    userId = json["userId"];
  }

  Map<String, String> toJson() {
    return {
      'userEmail': userEmail!,
      'userId': userId!,
    };
  }
}
