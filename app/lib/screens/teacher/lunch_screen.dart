// 이 파일은 도시락을 관리하는 화면입니다.
// 위쪽에서 이번 주 날짜(월~금)를 고르고, 그 날짜의 메뉴와 마감 시간을 등록합니다.
// 아래에서는 그 날짜에 누가 무엇을 신청했는지, 메뉴별로 몇 개인지 확인하고 마감할 수 있습니다.

import 'package:flutter/material.dart';

import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';

/// 도시락 관리 화면
class LunchScreen extends StatefulWidget {
  const LunchScreen({super.key});

  @override
  State<LunchScreen> createState() => _LunchScreenState();
}

class _LunchScreenState extends State<LunchScreen> {
  final _data = MockDataService.instance;
  final _menuController = TextEditingController();

  /// 지금 보고 있는 날짜
  late DateTime _selectedDate;

  /// 마감 시각 (시, 분)
  int _deadlineHour = 10;
  int _deadlineMinute = 30;

  @override
  void initState() {
    super.initState();
    // 처음에는 오늘 날짜를 고릅니다. 오늘이 주말이면 이번 주 월요일을 고릅니다.
    final week = _data.thisWeekDates;
    final today = dateOnly(DateTime.now());
    _selectedDate = week.any((d) => d == today) ? today : week.first;
    _loadMenuIntoForm();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  /// 고른 날짜에 이미 등록된 메뉴가 있으면 입력칸에 미리 채워 넣습니다.
  void _loadMenuIntoForm() {
    final menu = _data.menuForDate(_selectedDate);
    _menuController.text = menu?.menuItems.join(', ') ?? '';
    _deadlineHour = menu?.deadline.hour ?? 10;
    _deadlineMinute = menu?.deadline.minute ?? 30;
  }

  /// 메뉴를 저장합니다. 쉼표로 구분해서 여러 개를 넣을 수 있습니다.
  void _saveMenu() {
    final items = _menuController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (items.isEmpty) {
      _toast('메뉴를 한 개 이상 입력하세요. (쉼표로 구분)');
      return;
    }
    _data.registerLunchMenu(
      date: _selectedDate,
      menuItems: items,
      deadline: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _deadlineHour,
        _deadlineMinute,
      ),
    );
    _toast('${formatDateKorean(_selectedDate)} 메뉴를 저장했습니다.');
  }

  /// 마감 버튼: 한 번 더 물어본 뒤 마감합니다.
  Future<void> _close() async {
    final ok = await showConfirmDialog(
      context,
      title: '신청 마감',
      message: '${formatDateKorean(_selectedDate)} 도시락 신청을 마감할까요?\n'
          '마감하면 학생이 더 이상 신청할 수 없습니다.',
      confirmText: '마감하기',
    );
    if (!ok || !mounted) return;
    _data.closeLunchDate(_selectedDate);
    _toast('${formatDateKorean(_selectedDate)} 신청을 마감했습니다.');
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
        final week = _data.thisWeekDates;
        final menu = _data.menuForDate(_selectedDate);
        final orders = _data.ordersForDate(_selectedDate);
        final counts = _data.orderCountsForDate(_selectedDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '도시락 관리',
              subtitle: '이번 주 ${formatDate(week.first)} ~ ${formatDate(week.last)}',
            ),

            // 날짜 고르기 (월~금)
            Wrap(
              spacing: 8,
              children: [
                for (final d in week)
                  ChoiceChip(
                    label: Text(formatDateKorean(d)),
                    selected: d == _selectedDate,
                    onSelected: (_) {
                      setState(() {
                        _selectedDate = d;
                        _loadMenuIntoForm();
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 왼쪽: 메뉴 등록 ────────────────────
                  SizedBox(
                    width: 360,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('메뉴 등록', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              formatDateKorean(_selectedDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _menuController,
                              decoration: const InputDecoration(
                                labelText: '메뉴 (쉼표로 구분)',
                                hintText: '예) 제육덮밥, 치킨마요덮밥',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('마감 시간'),
                                const SizedBox(width: 12),
                                DropdownButton<int>(
                                  value: _deadlineHour,
                                  items: [
                                    for (var h = 7; h <= 13; h++)
                                      DropdownMenuItem(
                                        value: h,
                                        child: Text('${two(h)}시'),
                                      ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _deadlineHour = v ?? 10),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: _deadlineMinute,
                                  items: [
                                    for (final m in [0, 30])
                                      DropdownMenuItem(
                                        value: m,
                                        child: Text('${two(m)}분'),
                                      ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _deadlineMinute = v ?? 0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: _saveMenu,
                                  icon: const Icon(Icons.save_outlined),
                                  label: const Text('메뉴 저장'),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed:
                                      (menu == null || menu.closed) ? null : _close,
                                  icon: const Icon(Icons.lock_outline),
                                  label: Text(
                                    menu?.closed == true ? '마감됨' : '마감',
                                  ),
                                ),
                              ],
                            ),
                            if (menu != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                '등록된 메뉴: ${menu.menuItems.join(', ')}\n'
                                '마감 시간: ${formatTime(menu.deadline)}\n'
                                '상태: ${menu.closed ? '마감' : '신청 받는 중'}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // ── 오른쪽: 신청 집계와 신청자 목록 ─────
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
                                  '신청 집계 (총 ${orders.length}건)',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                if (counts.isEmpty)
                                  const Text('아직 신청이 없습니다.')
                                else
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (final entry in counts.entries)
                                        Chip(
                                          avatar: const Icon(
                                            Icons.restaurant,
                                            size: 18,
                                          ),
                                          label: Text(
                                            '${entry.key}  ${entry.value}개',
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('신청자 목록', style: theme.textTheme.titleMedium),
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
                            child: orders.isEmpty
                                ? const EmptyState(
                                    message: '이 날짜에는 신청자가 없습니다.',
                                    icon: Icons.no_meals_outlined,
                                  )
                                : ListView.separated(
                                    itemCount: orders.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final o = orders[index];
                                      return ListTile(
                                        dense: true,
                                        title:
                                            Text(_data.labelOf(o.studentUid)),
                                        subtitle: Text(
                                          '신청 ${formatTime(o.orderedAt)}',
                                        ),
                                        trailing: Text(o.menuItem),
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
