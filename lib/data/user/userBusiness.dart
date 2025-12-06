import 'package:mygame/data/user/userData.dart';
import 'package:mygame/data/user/user.dart';

class UserBusiness {
  static final UserDatabase _db = UserDatabase.instance;
  User? _user;
  Future<void> AddStudyTime(Duration add) async {
    _user = await _db.getUser(1);
    final now = DateTime.now();
    final lastLogin = _user!.lastLoginDate ?? now;

    Duration oldSeconds = _user!.studiSecond ?? Duration(seconds: 0);

    Duration newSeconds;

    if (!isSameDay(lastLogin, now)) {
      newSeconds = add;
    } else {
      newSeconds = oldSeconds + add;
    }
    await _db.UpdateTime(newSeconds);
    await _db.UpdateLogDay();

    if(newSeconds>Duration(minutes:5))
    {
      _db.updateStreak();
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
