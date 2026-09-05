// 이 파일은 선생님용 웹 화면의 "틀"입니다.
// 왼쪽에 메뉴 목록(사이드바), 오른쪽에 선택한 메뉴의 내용이 나오는 구조입니다.
// 메뉴를 누르면 오른쪽 내용만 바뀌고, 사이드바는 그대로 남아 있습니다.

import 'package:flutter/material.dart';

import '../../services/mock_data_service.dart';
import '../login_screen.dart';
import 'complaint_screen.dart';
import 'dashboard_screen.dart';
import 'lunch_screen.dart';
import 'notice_screen.dart';
import 'penalty_screen.dart';
import 'question_screen.dart';
import 'student_account_screen.dart';
import 'student_list_screen.dart';

/// 사이드바 메뉴 한 칸의 정보 (아이콘 + 이름)
class _MenuItem {
  const _MenuItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// 선생님용 화면 전체 틀
class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  /// 지금 선택된 메뉴 번호 (0 = 대시보드)
  int _selectedIndex = 0;

  final MockDataService _data = MockDataService.instance;

  static const List<_MenuItem> _menus = [
    _MenuItem(Icons.dashboard_outlined, '대시보드'),
    _MenuItem(Icons.groups_outlined, '학생 목록'),
    _MenuItem(Icons.gavel_outlined, '벌점 부여'),
    _MenuItem(Icons.lunch_dining_outlined, '도시락 관리'),
    _MenuItem(Icons.help_outline, '질문 배정'),
    _MenuItem(Icons.support_agent_outlined, '민원 처리'),
    _MenuItem(Icons.campaign_outlined, '공지 작성'),
    _MenuItem(Icons.manage_accounts_outlined, '학생 계정 관리'),
  ];

  /// 선택된 메뉴에 해당하는 화면을 돌려줍니다.
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        // 대시보드에서 "학생 목록 보기" 같은 이동이 필요할 때 쓰라고
        // 메뉴를 바꾸는 방법을 함께 넘겨 줍니다.
        return DashboardScreen(onGoToMenu: _select);
      case 1:
        return const StudentListScreen();
      case 2:
        return const PenaltyScreen();
      case 3:
        return const LunchScreen();
      case 4:
        return const QuestionScreen();
      case 5:
        return const ComplaintScreen();
      case 6:
        return const NoticeScreen();
      case 7:
        return const StudentAccountScreen();
      default:
        return DashboardScreen(onGoToMenu: _select);
    }
  }

  void _select(int index) {
    setState(() => _selectedIndex = index);
  }

  /// 로그아웃하고 로그인 화면으로 돌아갑니다.
  void _logout() {
    _data.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teacher = _data.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Row(
        children: [
          // ── 왼쪽 사이드바 ──────────────────────────────
          // Container 대신 Material을 씁니다. ListTile은 배경색과
          // 눌렀을 때 퍼지는 효과를 가장 가까운 Material 위에 그리기 때문에,
          // 색만 있는 Container 안에 두면 Flutter가 경고를 냅니다.
          SizedBox(
            width: 236,
            child: Material(
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '독학재수학원',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: _menus.length,
                      itemBuilder: (context, index) {
                        final menu = _menus[index];
                        final selected = index == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            selected: selected,
                            selectedTileColor:
                                theme.colorScheme.primaryContainer,
                            selectedColor: theme.colorScheme.onPrimaryContainer,
                            leading: Icon(menu.icon, size: 20),
                            title: Text(menu.label),
                            onTap: () => _select(index),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(Icons.logout, size: 20),
                      title: const Text('로그아웃'),
                      onTap: _logout,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),

          // ── 오른쪽 내용 영역 ───────────────────────────
          Expanded(
            child: Column(
              children: [
                // 위쪽 띠: 지금 로그인한 선생님 이름을 보여 줍니다.
                Container(
                  height: 60,
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      Text(
                        _menus[_selectedIndex].label,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          (teacher?.name ?? '?').substring(0, 1),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${teacher?.name ?? '선생님'} ${teacher?.role.label ?? ''}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
