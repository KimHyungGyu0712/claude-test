// 이 파일은 대시보드 위쪽에 놓는 "숫자 요약 카드" 부품입니다.
// 아이콘 + 설명 + 큰 숫자를 한 장의 카드로 보여 줍니다.
// 오늘 도시락 신청 수, 대기 질문 수처럼 한눈에 볼 숫자를 표시할 때 씁니다.

import 'package:flutter/material.dart';

/// 숫자 하나를 크게 보여 주는 카드
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  /// 카드 설명 (예: '오늘 도시락 신청')
  final String label;

  /// 크게 보여 줄 숫자나 글자
  final String value;

  /// 왼쪽 아이콘
  final IconData icon;

  /// 강조 색
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
