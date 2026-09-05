// 이 파일은 "사람 한 명"의 정보를 담는 상자(클래스)를 정의합니다.
// 학생, 선생님, 관리자를 모두 이 AppUser 하나로 표현하고, 역할(role)로 구분합니다.
// 나중에 Firebase의 users 컬렉션 문서 하나가 이 AppUser 하나에 대응됩니다.

/// 사용자의 역할. 학생 / 선생님 / 관리자 세 가지만 존재합니다.
enum UserRole {
  student('학생'),
  teacher('선생님'),
  admin('관리자');

  const UserRole(this.label);

  /// 화면에 그대로 보여줄 한글 이름
  final String label;
}

/// 앱을 쓰는 사람 한 명의 정보
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    this.seatNumber,
    this.phone,
    required this.createdAt,
  });

  /// 사람마다 겹치지 않는 고유 번호(아이디). Firebase에서 자동으로 만들어 줍니다.
  final String uid;

  /// 이름
  final String name;

  /// 역할 (학생/선생님/관리자)
  final UserRole role;

  /// 좌석 번호. 학생만 가지고 있어서 없을 수도 있습니다(null).
  final int? seatNumber;

  /// 연락처(학생이면 보호자 연락처)
  final String? phone;

  /// 계정을 만든 날짜
  final DateTime createdAt;

  /// 목록에서 "12번 김민준"처럼 보여줄 때 쓰는 글자
  String get displayLabel =>
      seatNumber == null ? name : '$seatNumber번 $name';

  /// 값 일부만 바꾼 새 AppUser를 만들어 줍니다.
  /// (Dart에서는 만들어 둔 값을 바꾸지 않고 새로 만드는 방식이 실수가 적습니다.)
  AppUser copyWith({
    String? name,
    UserRole? role,
    int? seatNumber,
    String? phone,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      role: role ?? this.role,
      seatNumber: seatNumber ?? this.seatNumber,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}
