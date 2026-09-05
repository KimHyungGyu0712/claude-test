// 이 파일은 학생 계정을 만들고 관리하는 화면입니다(관리자 업무).
// 왼쪽에서 이름, 좌석번호, 보호자 연락처, 이메일을 넣어 학생을 등록합니다.
// 오른쪽 목록의 '비밀번호 초기화'는 지금은 안내 메시지만 뜹니다(3주차에 실제 동작).

import 'package:flutter/material.dart';

import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';

/// 학생 계정 관리 화면
class StudentAccountScreen extends StatefulWidget {
  const StudentAccountScreen({super.key});

  @override
  State<StudentAccountScreen> createState() => _StudentAccountScreenState();
}

class _StudentAccountScreenState extends State<StudentAccountScreen> {
  final _data = MockDataService.instance;
  final _nameController = TextEditingController();
  final _seatController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _seatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// 입력한 내용을 확인하고 학생을 추가합니다.
  void _addStudent() {
    final name = _nameController.text.trim();
    final seatText = _seatController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || seatText.isEmpty || phone.isEmpty || email.isEmpty) {
      _toast('모든 칸을 입력하세요.');
      return;
    }
    // int.tryParse: 글자를 숫자로 바꿔 봅니다. 숫자가 아니면 null이 나옵니다.
    final seat = int.tryParse(seatText);
    if (seat == null) {
      _toast('좌석번호는 숫자로 입력하세요.');
      return;
    }
    if (_data.students.any((s) => s.seatNumber == seat)) {
      _toast('이미 사용 중인 좌석번호입니다.');
      return;
    }

    _data.addStudent(
      name: name,
      seatNumber: seat,
      guardianPhone: phone,
      email: email,
    );
    _toast('$name 학생을 등록했습니다.');
    _nameController.clear();
    _seatController.clear();
    _phoneController.clear();
    _emailController.clear();
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
        final students = _data.students;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '학생 계정 관리',
              subtitle: '등록된 학생 ${students.length}명 · 계정은 학원에서 발급합니다.',
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 왼쪽: 학생 등록 ────────────────────
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
                            Text('학생 등록', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: '이름',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _seatController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '좌석번호',
                                hintText: '숫자만',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: '보호자 연락처',
                                hintText: '010-0000-0000',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: '로그인 이메일',
                                hintText: 'student@hagwon.kr',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _addStudent,
                              icon: const Icon(Icons.person_add_alt),
                              label: const Text('학생 등록'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '개인정보 보호를 위해 이름, 좌석번호, 보호자 연락처만 받습니다.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // ── 오른쪽: 학생 계정 목록 ──────────────
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: students.isEmpty
                          ? const EmptyState(message: '등록된 학생이 없습니다.')
                          : ListView.separated(
                              itemCount: students.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final s = students[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${s.seatNumber}'),
                                  ),
                                  title: Text(s.name),
                                  subtitle: Text(
                                    '${s.phone ?? '-'} · '
                                    '등록 ${formatDate(s.createdAt)}',
                                  ),
                                  trailing: OutlinedButton(
                                    onPressed: () {
                                      final message =
                                          _data.resetPassword(s.uid);
                                      _toast(message);
                                    },
                                    child: const Text('비밀번호 초기화'),
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
        );
      },
    );
  }
}
