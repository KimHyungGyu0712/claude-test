// 이 파일은 "보여 줄 자료가 하나도 없을 때" 화면 가운데에 띄우는 안내 부품입니다.
// 빈 화면을 그냥 두면 고장 난 것처럼 보이기 때문에, 아이콘과 설명을 같이 보여 줍니다.
// 목록 화면 여러 곳에서 똑같이 재사용합니다.

import 'package:flutter/material.dart';

/// 자료가 없을 때 보여 주는 안내 부품
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  /// 보여 줄 안내 문구
  final String message;

  /// 함께 보여 줄 아이콘
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
