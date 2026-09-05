// 이 파일은 "특정 날짜의 도시락 메뉴표"를 담는 상자(클래스)입니다.
// 하루에 메뉴가 여러 개(A식/B식 등) 있을 수 있어서 메뉴는 목록으로 가집니다.
// 나중에 Firebase의 lunch_menus 컬렉션 문서 하나에 대응됩니다.

/// 하루치 도시락 메뉴
class LunchMenu {
  LunchMenu({
    required this.id,
    required this.date,
    required this.menuItems,
    required this.deadline,
    this.closed = false,
  });

  /// 메뉴표를 구분하는 고유 번호
  final String id;

  /// 어떤 날짜의 메뉴인지 (시/분은 0으로 맞춰 둔 날짜)
  final DateTime date;

  /// 그날 고를 수 있는 메뉴 이름들 (예: ['제육덮밥', '치킨마요'])
  List<String> menuItems;

  /// 신청 마감 시각
  DateTime deadline;

  /// 마감 처리되었는지 여부. true면 더 이상 신청을 받지 않습니다.
  bool closed;
}
