import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mygame/data/user/user.dart';
import 'package:mygame/data/user/userData.dart';

class ProfileNoti extends ChangeNotifier {
  static final _db = UserDatabase.instance;
  User? _user;
  bool isLoading = false;
  String get name => _user?.name ?? "Dinh Hieu";
  int get streak => _user?.streak ?? 0;
  Duration get learnTime => _user?.studiSecond ?? Duration(seconds: 0);
  String get formatedTime=>"${learnTime.inMinutes}:${(learnTime.inSeconds % 60).toString().padLeft(2, '0')}";
  List<String> get listBadge=>_listBadge;
  double get streakValue=>(_user?.streak ?? 1)/7;
  double get timeValue=>(_user?.studiSecond ?? Duration(seconds: 0)).inSeconds/(5*50);
  int get level=>(_user?.level??1);
  String get logDay=>_user?.lastLoginDate!=null?"${_user!.lastLoginDate!.month}-${_user!.lastLoginDate!.month}":"${DateTime.now().month}-${DateTime.now().day}";
  int get goal=>_user?.goal??5;
  final List<String> _listBadge = [
    "assets/level-titan/attack.png",
    "assets/level-titan/armor.png",
    "assets/level-titan/beast.png",
    "assets/level-titan/cart.png",
    "assets/level-titan/collo.png",
    "assets/level-titan/female.png",
    "assets/level-titan/jaw.png",
    "assets/level-titan/warhammer.png",
  ];

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();
    _user = await _db.getUser(1);
    isLoading = false;
    notifyListeners();
  }
}
