// 이 파일은 공지사항 한 건의 정보를 담는 상자(클래스)입니다.
// 선생님이 공지를 쓰면 이 Notice 하나가 만들어집니다.
// 나중에 Firebase의 notices 컬렉션 문서 하나에 대응됩니다.

/// 공지사항 한 건
class Notice {
  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.important = false,
  });

  /// 공지를 구분하는 고유 번호
  final String id;

  /// 제목
  String title;

  /// 내용
  String content;

  /// 작성한 선생님 이름
  final String authorName;

  /// 작성 일시
  final DateTime createdAt;

  /// 중요 공지인지 여부. true면 목록에서 눈에 띄게 표시합니다.
  bool important;
}
