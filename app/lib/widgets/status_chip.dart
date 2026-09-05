// 이 파일은 상태(대기/배정/완료, 접수/처리중/완료)를 알약 모양으로 보여 주는 부품입니다.
// 상태마다 색을 다르게 해서 목록에서 한눈에 구분되도록 합니다.
// 질문 화면과 민원 화면에서 함께 씁니다.

import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/question.dart';

/// 색이 있는 작은 상태 표시
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  /// 질문 상태(대기/배정/완료)용 만들기
  factory StatusChip.question(QuestionStatus status) {
    final color = switch (status) {
      QuestionStatus.waiting => Colors.orange,
      QuestionStatus.assigned => Colors.blue,
      QuestionStatus.done => Colors.green,
    };
    return StatusChip(label: status.label, color: color);
  }

  /// 민원 상태(접수/처리중/완료)용 만들기
  factory StatusChip.complaint(ComplaintStatus status) {
    final color = switch (status) {
      ComplaintStatus.received => Colors.orange,
      ComplaintStatus.inProgress => Colors.blue,
      ComplaintStatus.done => Colors.green,
    };
    return StatusChip(label: status.label, color: color);
  }

  /// 알약 안에 쓸 글자
  final String label;

  /// 알약 색
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700ish,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 색을 조금 더 진하게 만들어 글자가 잘 보이게 하는 도우미
extension on Color {
  Color get shade700ish => Color.lerp(this, Colors.black, 0.25)!;
}
