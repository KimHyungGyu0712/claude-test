// 이 파일은 벌점 한 건의 정보를 담는 상자(클래스)입니다.
// "누가(학생), 왜(사유), 몇 점, 누가 줬는지(선생님), 언제" 를 기록합니다.
// 나중에 Firebase의 penalties 컬렉션 문서 하나에 대응됩니다.

/// 벌점 한 건
class Penalty {
  const Penalty({
    required this.id,
    required this.studentUid,
    required this.reason,
    required this.points,
    required this.teacherName,
    required this.createdAt,
  });

  /// 벌점 기록을 구분하는 고유 번호
  final String id;

  /// 벌점을 받은 학생의 uid
  final String studentUid;

  /// 사유 (예: 지각, 휴대폰 사용)
  final String reason;

  /// 점수
  final int points;

  /// 벌점을 준 선생님 이름
  final String teacherName;

  /// 부여한 일시
  final DateTime createdAt;
}
