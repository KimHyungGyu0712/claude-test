// 이 파일은 앱이 시작되는 곳입니다. 여기서부터 프로그램이 실행됩니다.
// 앱 전체의 색/글꼴 같은 기본 모양(테마)을 정하고, 첫 화면으로 로그인 화면을 띄웁니다.
// 3주차에 Firebase를 붙이면 이 파일 맨 위에 Firebase 초기화 코드가 한 줄 추가됩니다.

import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const HagwonApp());
}

/// 앱 전체를 감싸는 가장 바깥쪽 위젯
class HagwonApp extends StatelessWidget {
  const HagwonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '독학재수학원 관리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material 3: 구글이 만든 최신 디자인 규칙입니다.
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A5DB0)),
        visualDensity: VisualDensity.comfortable,
      ),
      home: const LoginScreen(),
    );
  }
}
