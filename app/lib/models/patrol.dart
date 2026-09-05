// 이 파일은 순찰(QR 스캔) 기록 한 건을 담는 상자(클래스)입니다.
// 선생님이 학생 자리에서 QR을 찍으면 이 기록 하나가 남습니다.
// 나중에 Firebase의 patrols 컬렉션 문서 하나에 대응됩니다.

/// 순찰 기록 한 건
class Patrol {
  const Patrol({
    required this.id,
    required this.studentUid,
    required this.teacherName,
    required this.scannedAt,
    this.note,
  });

  /// 순찰 기록을 구분하는 고유 번호
  final String id;

  /// 확인된 학생의 uid
  final String studentUid;

  /// 스캔한 선생님 이름
  final String teacherName;

  /// 스캔한 일시
  final DateTime scannedAt;

  /// 위치나 비고 (예: '3층 열람실', '자리 비움')
  final String? note;
}
