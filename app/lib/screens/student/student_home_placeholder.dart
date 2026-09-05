// 이 파일은 학생용 화면의 "자리만 잡아 둔" 임시 화면입니다.
// 이번 작업은 선생님용 웹 화면이 목표라서, 학생 앱은 아직 만들지 않았습니다.
// 나중에 이 파일 대신 도시락 신청, 질문 접수, 벌점 조회 화면들이 들어갑니다.

import 'package:flutter/material.dart';

import '../../services/mock_data_service.dart';
import '../login_screen.dart';

/// 학생 앱 준비 중 안내 화면
class StudentHomePlaceholder extends StatelessWidget {
  const StudentHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = MockDataService.instance;
    final name = data.currentUser?.displayLabel ?? '학생';

    return Scaffold(
      appBar: AppBar(
        title: const Text('학생 화면'),
        actions: [
          TextButton.icon(
            onPressed: () {
              data.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('로그아웃'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone_iphone,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('$name님, 환영합니다', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                '학생용 앱(도시락 신청, 질문 접수, 민원 신고, 공지 확인, 벌점 조회)은\n'
                '선생님용 웹 화면을 먼저 만든 뒤에 이어서 개발할 예정입니다.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
