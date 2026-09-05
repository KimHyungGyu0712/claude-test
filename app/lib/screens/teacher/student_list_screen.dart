// 이 파일은 학생 전체 목록을 보여 주는 화면입니다.
// 위쪽 검색칸에 이름이나 좌석번호를 적으면 목록이 바로 걸러집니다.
// 학생 줄을 누르면 그 학생의 벌점/도시락/질문 내역을 담은 창이 열립니다.

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_chip.dart';

/// 학생 목록 화면
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _data = MockDataService.instance;
  final _searchController = TextEditingController();

  /// 검색어. 글자를 칠 때마다 이 값이 바뀌고 화면이 다시 그려집니다.
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        final list = _data.searchStudents(_keyword);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '학생 목록',
              subtitle: '전체 ${_data.students.length}명 중 ${list.length}명 표시',
            ),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _keyword = value),
                decoration: InputDecoration(
                  hintText: '이름 또는 좌석번호로 검색',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _keyword.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _keyword = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: list.isEmpty
                    ? const EmptyState(
                        message: '검색 결과가 없습니다.',
                        icon: Icons.search_off,
                      )
                    : Column(
                        children: [
                          // 표의 머리글 줄
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 70, child: Text('좌석')),
                                Expanded(flex: 3, child: Text('이름')),
                                Expanded(flex: 4, child: Text('보호자 연락처')),
                                Expanded(flex: 2, child: Text('누적 벌점')),
                                SizedBox(width: 90, child: Text('')),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final student = list[index];
                                final total =
                                    _data.totalPenaltyPoints(student.uid);
                                return InkWell(
                                  onTap: () =>
                                      _openStudentDetail(context, student),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Text('${student.seatNumber}번'),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            student.name,
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(student.phone ?? '-'),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '$total점',
                                            style: TextStyle(
                                              color: total >= 10
                                                  ? Colors.red
                                                  : null,
                                              fontWeight: total >= 10
                                                  ? FontWeight.bold
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 90,
                                          child: Text(
                                            '상세 보기',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 학생 한 명의 상세 내역 창을 엽니다.
  void _openStudentDetail(BuildContext context, AppUser student) {
    showDialog<void>(
      context: context,
      builder: (context) => _StudentDetailDialog(student: student),
    );
  }
}

/// 학생 상세 내역 창 (벌점 / 도시락 / 질문)
class _StudentDetailDialog extends StatelessWidget {
  const _StudentDetailDialog({required this.student});

  final AppUser student;

  @override
  Widget build(BuildContext context) {
    final data = MockDataService.instance;
    final theme = Theme.of(context);
    final penalties = data.penaltiesOf(student.uid);
    final orders = data.lunchOrdersOf(student.uid);
    final questions = data.questionsOf(student.uid);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      student.displayLabel,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                '보호자 연락처 ${student.phone ?? '-'} · '
                '등록일 ${formatDate(student.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '누적 벌점 ${data.totalPenaltyPoints(student.uid)}점 '
                  '(${penalties.length}건)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _section(context, '벌점 내역'),
                    if (penalties.isEmpty)
                      _emptyLine(context, '벌점 내역이 없습니다.')
                    else
                      for (final p in penalties)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${p.reason} · ${p.points}점'),
                          subtitle: Text(
                            '${formatDateTime(p.createdAt)} · ${p.teacherName}',
                          ),
                        ),
                    const SizedBox(height: 12),
                    _section(context, '도시락 신청 내역'),
                    if (orders.isEmpty)
                      _emptyLine(context, '도시락 신청 내역이 없습니다.')
                    else
                      for (final o in orders)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(o.menuItem),
                          subtitle: Text(formatDateKorean(o.date)),
                        ),
                    const SizedBox(height: 12),
                    _section(context, '질문 내역'),
                    if (questions.isEmpty)
                      _emptyLine(context, '질문 내역이 없습니다.')
                    else
                      for (final q in questions)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('[${q.subject}] ${q.content}'),
                          subtitle: Text(formatDateTime(q.createdAt)),
                          trailing: StatusChip.question(q.status),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 작은 구역 제목
  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      );

  /// 내역이 없을 때 한 줄 안내
  Widget _emptyLine(BuildContext context, String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
}
