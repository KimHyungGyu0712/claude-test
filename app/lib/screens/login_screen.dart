// 이 파일은 앱을 켰을 때 가장 먼저 보이는 로그인 화면입니다.
// 이메일과 비밀번호 칸이 있지만, 지금은 무엇을 입력해도 통과합니다(가짜 로그인).
// 3주차에 Firebase Authentication을 붙이면 실제 계정 확인으로 바뀝니다.

import 'package:flutter/material.dart';

import '../services/mock_data_service.dart';
import 'student/student_home_placeholder.dart';
import 'teacher/teacher_shell.dart';

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController는 입력칸에 적힌 글자를 읽어 오는 도구입니다.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _data = MockDataService.instance;

  @override
  void dispose() {
    // 화면이 사라질 때 도구도 정리해 줍니다(메모리 낭비 방지).
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 선생님 화면으로 들어갑니다.
  void _goTeacher() {
    _data.loginAsTeacher();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TeacherShell()),
    );
  }

  /// 학생 화면(아직 안내문만 있는 임시 화면)으로 들어갑니다.
  void _goStudent() {
    _data.loginAsStudent();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StudentHomePlaceholder()),
    );
  }

  /// 로그인 버튼: 지금은 입력 내용과 상관없이 선생님 화면으로 갑니다.
  void _login() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('지금은 체험용이라 아무 입력이나 통과합니다. 선생님 화면으로 이동합니다.'),
      ),
    );
    _goTeacher();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '독학재수학원 관리',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '학원에서 발급한 계정으로 로그인하세요',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        hintText: 'teacher@hagwon.kr',
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      onSubmitted: (_) => _login(),
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _login,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('로그인'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '체험하기',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _goTeacher,
                            icon: const Icon(Icons.co_present_outlined),
                            label: const Text('선생님으로 체험'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _goStudent,
                            icon: const Icon(Icons.person_outline),
                            label: const Text('학생으로 체험'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
