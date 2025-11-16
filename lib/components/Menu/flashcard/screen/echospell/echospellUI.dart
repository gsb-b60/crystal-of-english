import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';

class EchospellUI extends StatefulWidget {
  const EchospellUI({super.key});

  @override
  State<EchospellUI> createState() => _EchospellUIState();
}

class _EchospellUIState extends State<EchospellUI> {
  String word = "Hello";
  String ipa = "/heˈləʊ/";
  List<String> list = ["H", "e", "l", "l", "o"];
  List<String> listWord=["_","_","_","_","_",];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBase,
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColor.darkBorder,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: LinearProgressIndicator(
          value: 0.1,
          backgroundColor: AppColor.darkCard,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.greenPrimary),
          minHeight: 18,
          borderRadius: BorderRadius.circular(9),
        ),
        backgroundColor: AppColor.darkBase,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Text(
                    "Tap to build the word.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.outlined(
                    onPressed: () {},
                    icon: Icon(
                      Icons.volume_up,
                      color: AppColor.darkBorder,
                      size: 30,
                    ),
                  ),
                  Text(
                    ipa,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children:List.generate(listWord.length, (index){
                  String value=listWord[index];
                  return Text(value,style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),);
                }),
              ),
              SizedBox(height: 50,),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,

                children: List.generate(list.length, (index) {
                  final value = list[index];
                  return AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: BoxBorder.all(color:AppColor.darkCard,width: 4 )
                        ),
                        child: Center(
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            //bottom: provider.answer ? 0 : -MediaQuery.of(context).size.height,
            bottom: -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ReviewScreen(
              onPressed: () {
                
              },
            ),
          ),
        ],
      ),
    );
  }
}


class ReviewScreen extends StatelessWidget {
  ReviewScreen({super.key, required this.onPressed});
  VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: Container(
          color: AppColor.darkSurface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  SizedBox(width: 30),
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColor.greenBright,
                    size: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Great job!",
                    style: TextStyle(
                      color: AppColor.greenBright,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  SizedBox(
                    width: 650,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        onPressed.call();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColor.greenPrimary,
                      ),
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                          color: AppColor.darkBase,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColor.greenAccent,

                              width: 6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}