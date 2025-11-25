import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/profile/Quest/questNoti.dart';
import 'package:provider/provider.dart';

class Quest extends StatefulWidget {
  const Quest({super.key});

  @override
  State<Quest> createState() => _QuestState();
}

class _QuestState extends State<Quest> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuestNoti()..getUser(),
      child: Consumer<QuestNoti>(
        builder: (context, provider, _) {
          if(provider.isLoading)
          {
            return CircularProgressIndicator();
          }
          return QuestScreen();
        },
      ),
    );
  }
}

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestNoti>();
    final reader = context.read<QuestNoti>();
    return Scaffold(
      backgroundColor: AppColor.darkBase,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 210,
                padding: const EdgeInsets.symmetric(horizontal: 90),
                decoration: BoxDecoration(color: AppColor.greenDeep),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: 90,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColor.lightText,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  provider.month,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.greenDeep,
                                    fontSize: 30,
                                    height: 0.7,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "November Ranking - Law Execution",
                              style: TextStyle(
                                color: AppColor.lightText,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.timelapse_rounded,
                                  color: AppColor.greyGreen,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "${provider.remainingdate} DAYS",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.greyGreen,
                                    fontSize: 25,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.greenFade,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/level-titan/warhammer.png",
                              ),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 80,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: AppColor.darkBase,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Earn 20 Quest Points",
                                style: TextStyle(
                                  color: AppColor.lightText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    provider.questPoint,
                                    style: TextStyle(
                                      color: AppColor.greenPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    " / ${provider.QuestGoal}",
                                    style: TextStyle(
                                      color: AppColor.darkBorder,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          LinearProgressIndicator(
                            color: AppColor.greenPrimary,
                            backgroundColor: AppColor.darkBorder,
                            value: provider.questVal,
                            minHeight: 20,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Daily Quest",
                          style: TextStyle(
                            color: AppColor.lightText,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.timelapse, color: AppColor.bronze),
                            Text(
                              " ${provider.remaining} Hours",
                              style: TextStyle(
                                fontSize: 30,
                                color: AppColor.bronze,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 90),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColor.darkBorder, width: 2),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(horizontal: 19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Learn ${provider.LessGoal} Lesson",
                                style: TextStyle(
                                  color: AppColor.lightText,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      color: AppColor.greenPrimary,
                                      backgroundColor: AppColor.darkBorder,
                                      value: provider.lessVal,
                                      minHeight: 20,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.checklist_sharp,
                                      color: AppColor.greenPrimary,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      reader.getUser();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey, thickness: 1),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(horizontal: 19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Success learn ${provider.RepGoad} times",
                                style: TextStyle(
                                  color: AppColor.lightText,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      color: AppColor.greenPrimary,
                                      backgroundColor: AppColor.darkBorder,
                                      value: provider.repVal,
                                      minHeight: 20,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  Icon(
                                    Icons.checklist_sharp,
                                    color: AppColor.greenPrimary,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey, thickness: 1),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(horizontal: 19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Learn ${provider.LearnGoal} Card",
                                style: TextStyle(
                                  color: AppColor.lightText,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      color: AppColor.greenPrimary,
                                      backgroundColor: AppColor.darkBorder,
                                      value: provider.learnVal,
                                      minHeight: 20,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.checklist_sharp,
                                      color: AppColor.greenPrimary,
                                      size: 30,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: AppColor.lightText),
            ),
          ),
        ],
      ),
    );
  }
}
