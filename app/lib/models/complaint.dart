// 이 파일은 학생이 넣은 민원 한 건을 담는 상자(클래스)입니다.
// 민원은 접수 → 처리중 → 완료 순서로 상태가 바뀌고, 선생님이 답변을 답니다.
// 나중에 Firebase의 complaints 컬렉션 문서 하나에 대응됩니다.

/// 민원의 처리 상태
enum ComplaintStatus {
  received('접수'),
  inProgress('처리중'),
  done('완료');

  const ComplaintStatus(this.label);

  /// 화면에 그대로 보여줄 한글 이름
  final String label;
}

/// 민원 한 건
class Complaint {
  Complaint({
    required this.id,
    required this.studentUid,
    required this.content,
    required this.createdAt,
    this.status = ComplaintStatus.received,
    this.reply,
    this.repliedAt,
  });

  /// 민원을 구분하는 고유 번호
  final String id;

  /// 민원을 넣은 학생의 uid
  final String studentUid;

  /// 민원 내용
  final String content;

  /// 접수한 시각
  final DateTime createdAt;

  /// 현재 상태 (접수/처리중/완료)
  ComplaintStatus status;

  /// 선생님 답변. 아직 답변 전이면 없습니다(null).
  String? reply;

  /// 답변한 시각
  DateTime? repliedAt;
}
