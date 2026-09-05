// 이 파일은 선생님이 로그인하면 가장 먼저 보는 대시보드 화면입니다.
// 오늘 꼭 확인해야 할 숫자 4개(도시락/질문/민원/벌점)와 최근 공지 3개를 보여 줍니다.
// 숫자는 모두 가짜 데이터 창고(MockDataService)에서 그때그때 계산해서 가져옵니다.

import 'package:flutter/material.dart';

import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/summary_card.dart';

/// 대시보드 화면
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onGoToMenu});

  /// 사이드바 메뉴를 바꿔 달라고 부탁하는 함수 (예: 공지 화면으로 이동)
  final void Function(int index) onGoToMenu;

  @override
  Widget build(BuildContext context) {
    final data = MockDataService.instance;
    final theme = Theme.of(context);

    // ListenableBuilder: 데이터 창고가 바뀌면 이 안쪽만 다시 그립니다.
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final latestNotices = data.notices.take(3).toList();

        return ListView(
          children: [
            PageHeader(
              title: '대시보드',
              subtitle: '${formatDateKorean(DateTime.now())} 기준 현황입니다.',
            ),

            // 숫자 요약 카드 4개. 화면 폭에 맞춰 자동으로 줄바꿈됩니다.
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth < 900
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 48) / 4;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        label: '오늘 도시락 신청',
                        value: '${data.todayLunchOrderCount}건',
                        icon: Icons.lunch_dining_outlined,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        label: '대기 중 질문',
                        value: '${data.waitingQuestionCount}건',
                        icon: Icons.help_outline,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        label: '미처리 민원',
                        value: '${data.openComplaintCount}건',
                        icon: Icons.support_agent_outlined,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        label: '오늘 부여된 벌점',
                        value: '${data.todayPenaltyCount}건',
                        icon: Icons.gavel_outlined,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // 최근 공지 3개
            Row(
              children: [
                Text('최근 공지', style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => onGoToMenu(6),
                  child: const Text('공지 작성으로 이동'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: latestNotices.isEmpty
                  ? const SizedBox(
                      height: 160,
                      child: EmptyState(message: '아직 등록된 공지가 없습니다.'),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < latestNotices.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              latestNotices[i].important
                                  ? Icons.priority_high
                                  : Icons.campaign_outlined,
                              color: latestNotices[i].important
                                  ? Colors.red
                                  : theme.colorScheme.outline,
                            ),
                            title: Text(latestNotices[i].title),
                            subtitle: Text(
                              latestNotices[i].content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              formatDate(latestNotices[i].createdAt),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
