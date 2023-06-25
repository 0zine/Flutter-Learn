import 'dart:math';

import 'package:flutter/material.dart';
import 'package:random_dice/screen/home_screen.dart';
import 'package:random_dice/screen/setting_screen.dart';
import 'package:shake/shake.dart';

class RootScreen extends StatefulWidget {

  const RootScreen({Key? key}) : super(key: key);

  @override
  State createState() => _RootScreenState();

}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {

  TabController? controller;
  double threshold = 2.7;
  int number = 1;
  ShakeDetector? shakeDetector;

  @override
  void initState() {
    super.initState();

    //컨트롤러 초기화
    controller = TabController(length: 2, vsync: this);
    controller!.addListener(tabListener);

    shakeDetector = ShakeDetector.autoStart(
        shakeSlopTimeMS: 100,
        shakeThresholdGravity: threshold,
        onPhoneShake: onPhoneShake,
    );
  }

  void onPhoneShake() {
    final rand = Random();
    setState(() {
      number = rand.nextInt(5) +1;
    });
  }

  tabListener()  {
    setState(() {

    });
  }

  @override
  void dispose() {
    controller!.removeListener(tabListener);
    shakeDetector!.stopListening();  //흔들기 감지 중지
    super.dispose();
  }

  List<Widget> renderChildren() {
    return [
      
      HomeScreen(
        number: number,
      ),
      SettingsScreen(
          threshold: threshold,
          onThresholdChange: onThresholdChange
      ),

    ];
  }

  void onThresholdChange(double val) {
    setState(() {
      threshold = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: renderChildren(),
      ),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }

  BottomNavigationBar renderBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: controller!.index,
      onTap: (int index) {
        setState(() {
          controller!.animateTo(index);
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.edgesensor_high_outlined,
          ),
          label: '주사위'
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: '설정'
        ),
      ]
    );
  }


}