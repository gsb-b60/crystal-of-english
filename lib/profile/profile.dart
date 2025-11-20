import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mygame/components/Menu/Theme/color.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<String> listBadge = [
    "assets/level-titan/attack.png",
    "assets/level-titan/armor.png",
    "assets/level-titan/beast.png",
    "assets/level-titan/cart.png",
    "assets/level-titan/collo.png",
    "assets/level-titan/female.png",
    "assets/level-titan/jaw.png",
    "assets/level-titan/warhammer.png",
  ];

  @override
  Widget build(BuildContext context) {
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
                      "Name",
                      style: TextStyle(
                        color: AppColor.lightText,
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        height: 0.7,
                      ),
                    ),
                    Text(
                      "LEVEL X",
                      style: TextStyle(color: AppColor.lightText, fontSize: 22),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InfoBox(ico: Icons.bolt, line: "Streak Days", value: "X"),
                    InfoBox(ico: Icons.bolt, line: "Streak Days", value: "X"),
                    InfoBox(ico: Icons.bolt, line: "Streak Days", value: "X"),
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
                          SizedBox(width: 15),
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
          VerticalDivider(
            color: const Color.fromARGB(255, 255, 255, 255), // màu vạch
            thickness: 1, // độ dày vạch
            width: 20, // khoảng trống dành cho vạch
            indent: 8, // cách trên
            endIndent: 8, // cách dưới
          ),
          Expanded(
            child: Container(
              child: Column(
                spacing: 20,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 78,
                        color: AppColor.bluePrimary,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Time Goal",
                            style: TextStyle(
                              color: AppColor.bluePrimary,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              height: 0.5,
                            ),
                          ),
                          Text(
                            "learn enough to make a streak",
                            style: TextStyle(
                              color: AppColor.lightText,
                              fontSize: 27,
                            ),
                          ),
                          SizedBox(
                            height: 20, // chiều cao progress bar
                            width: 280,
                            child: LinearProgressIndicator(
                              value: 0.1,
                              color: AppColor.bluePrimary,
                              backgroundColor: AppColor.darkBorder,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "X/5 MIN",
                            style: TextStyle(
                              color: AppColor.bluePrimary,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 78,
                        color: AppColor.redPrimary,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Streak Goal",
                            style: TextStyle(
                              color: AppColor.redPrimary,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              height: 0.5,
                            ),
                          ),
                          Text(
                            "learn enough to make a streak",
                            style: TextStyle(
                              color: AppColor.lightText,
                              fontSize: 27,
                            ),
                          ),
                          SizedBox(
                            height: 20, // chiều cao progress bar
                            width: 280,
                            child: LinearProgressIndicator(
                              value: 0.1,
                              color: AppColor.redPrimary,
                              backgroundColor: AppColor.darkBorder,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "X/7 DAY",
                            style: TextStyle(
                              color: AppColor.redPrimary,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ico, color: AppColor.yellowPrimary),
          Column(
            children: [
              Text(line, style: TextStyle(color: AppColor.lightText)),
              Text(
                value,
                style: TextStyle(
                  color: AppColor.lightText,
                  fontSize: 30,
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
