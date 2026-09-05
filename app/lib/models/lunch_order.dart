// 이 파일은 학생 한 명이 신청한 도시락 한 건을 담는 상자(클래스)입니다.
// "어느 날짜에, 어떤 학생이, 어떤 메뉴를 골랐는지"를 기록합니다.
// 나중에 Firebase의 lunch_orders 컬렉션 문서 하나에 대응됩니다.

/// 도시락 신청 한 건
class LunchOrder {
  LunchOrder({
    required this.id,
    required this.date,
    required this.studentUid,
    required this.menuItem,
    required this.orderedAt,
    this.cancelled = false,
  });

  /// 신청 건을 구분하는 고유 번호
  final String id;

  /// 신청한 날짜(어느 날 먹을 도시락인지)
  final DateTime date;

  /// 신청한 학생의 uid
  final String studentUid;

  /// 고른 메뉴 이름
  String menuItem;

  /// 신청한 시각
  final DateTime orderedAt;

  /// 취소되었는지 여부
  bool cancelled;
}
