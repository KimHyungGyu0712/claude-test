// 이 파일은 모든 선생님 화면 맨 위에 똑같이 들어가는 "제목 줄"입니다.
// 큰 제목, 작은 설명, 오른쪽 버튼 자리를 한 번에 만들어 줍니다.
// 화면마다 같은 코드를 반복해서 쓰지 않으려고 부품으로 따로 빼 두었습니다.

import 'package:flutter/material.dart';

/// 화면 상단 제목 줄
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  /// 큰 제목 (예: '벌점 부여')
  final String title;

  /// 제목 아래 작은 설명 글
  final String? subtitle;

  /// 오른쪽에 놓을 버튼들
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
