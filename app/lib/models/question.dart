// 이 파일은 학생이 접수한 질문 한 건을 담는 상자(클래스)입니다.
// 질문은 대기 → 배정 → 완료 순서로 상태가 바뀝니다.
// 나중에 Firebase의 questions 컬렉션 문서 하나에 대응됩니다.

/// 질문의 처리 상태
enum QuestionStatus {
  waiting('대기'),
  assigned('배정'),
  done('완료');

  const QuestionStatus(this.label);

  /// 화면에 그대로 보여줄 한글 이름
  final String label;
}

/// 질문 한 건
class Question {
  Question({
    required this.id,
    required this.studentUid,
    required this.subject,
    required this.content,
    required this.createdAt,
    this.status = QuestionStatus.waiting,
    this.assignedAt,
    this.teacherName,
  });

  /// 질문을 구분하는 고유 번호
  final String id;

  /// 질문한 학생의 uid
  final String studentUid;

  /// 과목 (예: 수학)
  final String subject;

  /// 질문 내용
  final String content;

  /// 접수한 시각
  final DateTime createdAt;

  /// 현재 상태 (대기/배정/완료)
  QuestionStatus status;

  /// 배정된 시각. 아직 배정 전이면 없습니다(null).
  DateTime? assignedAt;

  /// 담당 선생님 이름. 아직 배정 전이면 없습니다(null).
  String? teacherName;
}
