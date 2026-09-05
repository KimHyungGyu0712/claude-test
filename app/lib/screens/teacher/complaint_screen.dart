// 이 파일은 학생이 넣은 민원을 처리하는 화면입니다.
// 민원마다 상태를 접수 → 처리중 → 완료로 바꾸고, 답변을 적을 수 있습니다.
// 위쪽 버튼으로 상태별로 걸러서 볼 수 있습니다.

import 'package:flutter/material.dart';

import '../../models/complaint.dart';
import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_chip.dart';

/// 민원 처리 화면
class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _data = MockDataService.instance;

  /// 지금 고른 상태 필터. null이면 전체.
  ComplaintStatus? _filter;

  /// 답변 작성 창을 띄웁니다.
  Future<void> _openReplyDialog(Complaint complaint) async {
    final controller = TextEditingController(text: complaint.reply ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답변 작성'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('민원 내용: ${complaint.content}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '답변 내용',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    final text = controller.text.trim();
    controller.dispose();
    if (saved != true || !mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변 내용을 입력하세요.')),
      );
      return;
    }
    _data.replyToComplaint(complaint.id, text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('답변을 저장했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        final list = _data.complaintsByStatus(_filter);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '민원 처리',
              subtitle: '아직 처리되지 않은 민원 ${_data.openComplaintCount}건',
            ),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('전체'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final s in ComplaintStatus.values)
                  ChoiceChip(
                    label: Text(s.label),
                    selected: _filter == s,
                    onSelected: (_) => setState(() => _filter = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      message: '해당하는 민원이 없습니다.',
                      icon: Icons.support_agent_outlined,
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final c = list[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusChip.complaint(c.status),
                                    const SizedBox(width: 10),
                                    Text(
                                      _data.labelOf(c.studentUid),
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatDateTime(c.createdAt),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(c.content),
                                if (c.reply != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '답변',
                                          style: theme.textTheme.labelMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(c.reply!),
                                        if (c.repliedAt != null)
                                          Text(
                                            formatDateTime(c.repliedAt!),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _openReplyDialog(c),
                                      icon: const Icon(Icons.edit_outlined),
                                      label: Text(
                                        c.reply == null ? '답변 작성' : '답변 수정',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (c.status == ComplaintStatus.received)
                                      FilledButton(
                                        onPressed: () =>
                                            _data.updateComplaintStatus(
                                          c.id,
                                          ComplaintStatus.inProgress,
                                        ),
                                        child: const Text('처리중으로 변경'),
                                      ),
                                    if (c.status == ComplaintStatus.inProgress)
                                      FilledButton(
                                        onPressed: () =>
                                            _data.updateComplaintStatus(
                                          c.id,
                                          ComplaintStatus.done,
                                        ),
                                        child: const Text('완료로 변경'),
                                      ),
                                    if (c.status == ComplaintStatus.done)
                                      TextButton(
                                        onPressed: () =>
                                            _data.updateComplaintStatus(
                                          c.id,
                                          ComplaintStatus.inProgress,
                                        ),
                                        child: const Text('처리중으로 되돌리기'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
