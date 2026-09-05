// 이 파일은 학생이 접수한 질문을 선생님에게 배정하는 화면입니다.
// 위쪽 버튼으로 전체/대기/배정/완료를 골라 볼 수 있습니다.
// '대기' 질문은 시간과 담당 선생님을 정하면 '배정'으로, 상담이 끝나면 '완료'로 바뀝니다.

import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_chip.dart';

/// 질문 배정 화면
class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _data = MockDataService.instance;

  /// 지금 고른 상태 필터. null이면 전체를 봅니다.
  QuestionStatus? _filter;

  /// 배정 창을 띄우고, 시간과 선생님을 고르면 저장합니다.
  Future<void> _openAssignDialog(Question question) async {
    final teachers = _data.teachers;
    String teacherName = teachers.first.name;
    TimeOfDay time = const TimeOfDay(hour: 16, minute: 0);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        // StatefulBuilder: 창 안에서만 값이 바뀌도록 도와줍니다.
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('질문 배정'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_data.labelOf(question.studentUid)} · '
                      '${question.subject}',
                    ),
                    const SizedBox(height: 4),
                    Text(question.content),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('담당 선생님')),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: teacherName,
                            items: [
                              for (final t in teachers)
                                DropdownMenuItem(
                                  value: t.name,
                                  child: Text(t.name),
                                ),
                            ],
                            onChanged: (v) => setDialogState(
                              () => teacherName = v ?? teacherName,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('배정 시간')),
                        Text('${two(time.hour)}:${two(time.minute)}'),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (picked != null) {
                              setDialogState(() => time = picked);
                            }
                          },
                          child: const Text('시간 선택'),
                        ),
                      ],
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
                  child: const Text('배정하기'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !mounted) return;

    final today = DateTime.now();
    _data.assignQuestion(
      questionId: question.id,
      assignedAt: DateTime(
        today.year,
        today.month,
        today.day,
        time.hour,
        time.minute,
      ),
      teacherName: teacherName,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$teacherName 선생님, ${two(time.hour)}:${two(time.minute)}로 배정했습니다.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        final list = _data.questionsByStatus(_filter);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '질문 배정',
              subtitle: '대기 중인 질문 ${_data.waitingQuestionCount}건',
            ),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('전체'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final s in QuestionStatus.values)
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
                      message: '해당하는 질문이 없습니다.',
                      icon: Icons.help_outline,
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final q = list[index];
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          StatusChip.question(q.status),
                                          const SizedBox(width: 10),
                                          Text(
                                            '[${q.subject}] '
                                            '${_data.labelOf(q.studentUid)}',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(q.content),
                                      const SizedBox(height: 8),
                                      Text(
                                        '접수 ${formatDateTime(q.createdAt)}'
                                        '${q.assignedAt == null ? '' : '  ·  배정 ${formatDateTime(q.assignedAt!)} (${q.teacherName})'}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    if (q.status == QuestionStatus.waiting)
                                      FilledButton(
                                        onPressed: () => _openAssignDialog(q),
                                        child: const Text('배정하기'),
                                      ),
                                    if (q.status == QuestionStatus.assigned)
                                      OutlinedButton(
                                        onPressed: () =>
                                            _data.completeQuestion(q.id),
                                        child: const Text('완료 처리'),
                                      ),
                                    if (q.status == QuestionStatus.done)
                                      const Text('처리 완료'),
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
