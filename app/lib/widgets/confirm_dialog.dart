// 이 파일은 "정말 하시겠습니까?" 하고 한 번 더 물어보는 작은 창을 만들어 줍니다.
// 삭제나 마감처럼 되돌리기 어려운 행동 앞에서 실수를 막는 역할입니다.
// true(예)를 돌려주면 실행하고, false/null(아니오)면 아무것도 하지 않습니다.

import 'package:flutter/material.dart';

/// 확인 창을 띄우고, 사용자가 '확인'을 누르면 true를 돌려줍니다.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = '확인',
  String cancelText = '취소',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
