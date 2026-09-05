// 이 파일은 앱이 오류 없이 켜지는지 자동으로 확인하는 아주 간단한 테스트입니다.
// 로그인 화면이 제대로 나타나는지만 봅니다(연기 테스트, smoke test).
// 터미널에서 `flutter test` 를 치면 실행됩니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hagwon_app/main.dart';

void main() {
  testWidgets('앱을 켜면 로그인 화면이 보인다', (WidgetTester tester) async {
    // 앱을 화면에 그려 봅니다.
    await tester.pumpWidget(const HagwonApp());

    // 로그인 화면에 있어야 할 글자들이 실제로 보이는지 확인합니다.
    expect(find.text('독학재수학원 관리'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '로그인'), findsOneWidget);
    expect(find.text('선생님으로 체험'), findsOneWidget);
    expect(find.text('학생으로 체험'), findsOneWidget);
  });
}
