// 이 파일은 선생님이 학생에게 벌점을 주는 화면입니다.
// 왼쪽에서 학생을 찾아 고르고 사유와 점수를 적어 '벌점 부여'를 누르면 바로 저장됩니다.
// 아래쪽 '최근 벌점 내역' 목록이 즉시 갱신되어 방금 준 벌점을 확인할 수 있습니다.

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';

/// 벌점 부여 화면
class PenaltyScreen extends StatefulWidget {
  const PenaltyScreen({super.key});

  @override
  State<PenaltyScreen> createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  final _data = MockDataService.instance;
  final _searchController = TextEditingController();
  final _reasonController = TextEditingController();

  /// 고른 학생. 아직 안 골랐으면 null.
  AppUser? _selected;

  /// 입력한 점수 (기본 1점)
  int _points = 1;

  /// 자주 쓰는 사유 목록. 누르면 사유칸이 자동으로 채워집니다.
  static const _quickReasons = [
    '지각',
    '무단 외출',
    '휴대폰 사용',
    '자습 중 잡담',
    '자습실 취식',
    '복장 불량',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  /// 입력한 내용을 확인하고 벌점을 저장합니다.
  void _submit() {
    final student = _selected;
    final reason = _reasonController.text.trim();
    if (student == null) {
      _toast('학생을 먼저 선택하세요.');
      return;
    }
    if (reason.isEmpty) {
      _toast('사유를 입력하세요.');
      return;
    }
    _data.addPenalty(
      studentUid: student.uid,
      reason: reason,
      points: _points,
    );
    _toast('${student.displayLabel} 학생에게 $reason $_points점을 부여했습니다.');
    setState(() {
      _reasonController.clear();
      _points = 1;
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        final candidates = _data.searchStudents(_searchController.text);
        final recent = _data.penalties.take(15).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: '벌점 부여',
              subtitle: '학생을 고르고 사유와 점수를 입력하세요.',
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 왼쪽: 학생 고르기 ──────────────────
                  SizedBox(
                    width: 320,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: '이름 또는 좌석번호 검색',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: candidates.length,
                              itemBuilder: (context, index) {
                                final s = candidates[index];
                                return ListTile(
                                  dense: true,
                                  selected: _selected?.uid == s.uid,
                                  selectedTileColor:
                                      theme.colorScheme.primaryContainer,
                                  title: Text(s.displayLabel),
                                  trailing: Text(
                                    '${_data.totalPenaltyPoints(s.uid)}점',
                                  ),
                                  onTap: () => setState(() => _selected = s),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // ── 오른쪽: 입력 + 최근 내역 ───────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selected == null
                                      ? '선택된 학생: 없음'
                                      : '선택된 학생: ${_selected!.displayLabel}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _reasonController,
                                  decoration: const InputDecoration(
                                    labelText: '사유',
                                    hintText: '예) 자습 중 휴대폰 사용',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    for (final r in _quickReasons)
                                      ActionChip(
                                        label: Text(r),
                                        onPressed: () =>
                                            _reasonController.text = r,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Text('점수'),
                                    const SizedBox(width: 12),
                                    DropdownButton<int>(
                                      value: _points,
                                      items: [
                                        for (final p in [1, 2, 3, 5, 10])
                                          DropdownMenuItem(
                                            value: p,
                                            child: Text('$p점'),
                                          ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => _points = v ?? 1),
                                    ),
                                    const Spacer(),
                                    FilledButton.icon(
                                      onPressed: _submit,
                                      icon: const Icon(Icons.add),
                                      label: const Text('벌점 부여'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('최근 벌점 내역', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: recent.isEmpty
                                ? const EmptyState(message: '아직 벌점 내역이 없습니다.')
                                : ListView.separated(
                                    itemCount: recent.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final p = recent[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          '${_data.labelOf(p.studentUid)} · '
                                          '${p.reason}',
                                        ),
                                        subtitle: Text(
                                          '${formatDateTime(p.createdAt)} · '
                                          '${p.teacherName}',
                                        ),
                                        trailing: Text(
                                          '${p.points}점',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
