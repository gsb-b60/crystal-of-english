import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/profile/profileNoti.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  

  @override
  Widget build(BuildContext context) {
    final provider=context.watch<ProfileNoti>();
    final listBadge=provider.listBadge;
    final name=provider.name;
    final learnTime=provider.learnTime;
    final streak=provider.streak;
    return Scaffold(
      backgroundColor: AppColor.darkBase,
      appBar: AppBar(
        title: Text(
          "PROFILE",
          style: TextStyle(color: AppColor.lightText, fontSize: 34),
        ),
        backgroundColor: AppColor.darkBase,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColor.lightText),
        ),
      ),
      body: Row(
        children: [
          Container(
            height: double.infinity,
            width: 300,
            decoration: BoxDecoration(),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 53,
                  backgroundImage: AssetImage("assets/level-titan/cart.png"),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: AppColor.lightText,
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        height: 0.7,
                      ),
                    ),
                    Text(
                      "LEVEL ${provider.level}",
                      style: TextStyle(color: AppColor.lightText, fontSize: 22),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InfoBox(ico: Icons.bolt, line: "Streak Days", value: provider.streak.toString()),
                    InfoBox(ico: Icons.calendar_month, line: "Log Day", value: provider.logDay),
                    InfoBox(ico: Icons.bolt, line: "GOAL", value: provider.goal.toString()),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Badges",
                      style: TextStyle(color: AppColor.lightText, fontSize: 30),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listBadge.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          SizedBox(width: 9),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.yellowPrimary,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: AssetImage(listBadge[index]),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  SizedBox(height: 20),
                  ProgressBlock(
                    ico: Icons.timer,
                    name: "Learn Time",
                    value: provider.timeValue,
                    line: "learn enought to earn a streak!",
                    indicate: "${learnTime.inMinutes}/5 MIN",
                    co: AppColor.bluePrimary,
                    realValue: provider.formatedTime,
                  ),
                  ProgressBlock(
                    ico: Icons.local_fire_department_outlined,
                    name: "Streak Goal",
                    value: provider.streakValue,
                    line: "Show Me Who Really Learn!",
                    indicate: " ${streak}/7 Day",
                    co: AppColor.redPrimary,
                    realValue: "",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBlock extends StatelessWidget {
  ProgressBlock({
    super.key,
    required this.ico,
    required this.name,
    required this.line,
    required this.indicate,
    required this.value,
    required this.co,
    required this.realValue
  });
  IconData ico;
  String name;
  String line;
  String indicate;
  double value;
  Color co;
  String realValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.darkBorder,width: 2)
        
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(ico, size: 58, color: co),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: co,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  height: 0.5,
                ),
              ),
              Text(
                line,
                style: TextStyle(color: AppColor.lightText, fontSize: 27),
              ),
              SizedBox(
                height: 20, // chiều cao progress bar
                width: 280,
                child: LinearProgressIndicator(
                  value: value,
                  color: co,
                  backgroundColor: AppColor.darkBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(indicate, style: TextStyle(color: co, fontSize: 30)),
              Text(realValue, style: TextStyle(color: co, fontSize: 30)),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  InfoBox({
    super.key,
    required this.ico,
    required this.line,
    required this.value,
  });
  IconData ico;
  String line;
  String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 50,
      decoration: BoxDecoration(
        border: BoxBorder.all(color: AppColor.darkBorder, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(ico, color: AppColor.yellowPrimary),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Text(line, style: TextStyle(color: AppColor.lightText)),
              Text(
                value,
                style: TextStyle(
                  color: AppColor.lightText,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  height: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
