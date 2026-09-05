// 이 파일은 "가짜 데이터 창고"입니다. 아직 서버(Firebase)를 붙이지 않았기 때문에
// 학생/공지/벌점/도시락/질문/민원 자료를 앱 메모리 안에만 들고 있습니다.
// 화면들은 이 창고에 값을 묻고, 값이 바뀌면 창고가 "바뀌었다"고 알려 화면이 다시 그려집니다.
//
// ★ 3주차에 이 파일은 Firebase(Cloud Firestore) 통신 코드로 통째로 바뀝니다.
//   지금은 앱을 새로고침하면 여기서 만든 내용이 모두 사라집니다(저장되지 않습니다).

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/complaint.dart';
import '../models/lunch_menu.dart';
import '../models/lunch_order.dart';
import '../models/notice.dart';
import '../models/patrol.dart';
import '../models/penalty.dart';
import '../models/question.dart';
import 'format_utils.dart';

/// 앱 전체가 함께 쓰는 가짜 데이터 창고.
///
/// ChangeNotifier를 물려받았기 때문에 `notifyListeners()`를 부르면
/// 이 창고를 보고 있는 화면들이 자동으로 다시 그려집니다.
class MockDataService extends ChangeNotifier {
  MockDataService() {
    _seed();
  }

  /// 앱 어디서나 같은 창고를 쓰도록 하나만 만들어 둡니다.
  static final MockDataService instance = MockDataService();

  // ── 저장소(그냥 목록입니다) ──────────────────────────────
  final List<AppUser> _users = [];
  final List<Notice> _notices = [];
  final List<Penalty> _penalties = [];
  final List<LunchMenu> _lunchMenus = [];
  final List<LunchOrder> _lunchOrders = [];
  final List<Question> _questions = [];
  final List<Complaint> _complaints = [];
  final List<Patrol> _patrols = [];

  /// 새 자료에 붙일 번호를 만들기 위한 카운터
  int _idCounter = 0;
  String _newId(String prefix) => '$prefix${++_idCounter}';

  /// 지금 로그인한 사람. 로그인 전에는 없습니다(null).
  AppUser? currentUser;

  // ── 읽기 전용 목록 ────────────────────────────────────────
  List<AppUser> get users => List.unmodifiable(_users);

  /// 학생만 좌석번호 순서로
  List<AppUser> get students =>
      _users.where((u) => u.role == UserRole.student).toList()
        ..sort((a, b) => (a.seatNumber ?? 0).compareTo(b.seatNumber ?? 0));

  /// 선생님(관리자 포함)
  List<AppUser> get teachers =>
      _users.where((u) => u.role != UserRole.student).toList();

  /// 공지 목록 (최신 글이 위로)
  List<Notice> get notices =>
      _notices.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 벌점 목록 (최신이 위로)
  List<Penalty> get penalties =>
      _penalties.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 질문 목록 (최신이 위로)
  List<Question> get questions =>
      _questions.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 민원 목록 (최신이 위로)
  List<Complaint> get complaints =>
      _complaints.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 도시락 메뉴표 목록 (날짜 순)
  List<LunchMenu> get lunchMenus =>
      _lunchMenus.toList()..sort((a, b) => a.date.compareTo(b.date));

  /// 순찰 기록 목록 (최신이 위로)
  List<Patrol> get patrols =>
      _patrols.toList()..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

  // ── 로그인 ───────────────────────────────────────────────

  /// 선생님으로 체험 로그인 (지금은 아무 입력이나 통과시키는 임시 방식)
  void loginAsTeacher() {
    currentUser = _users.firstWhere((u) => u.role == UserRole.teacher);
    notifyListeners();
  }

  /// 학생으로 체험 로그인
  void loginAsStudent() {
    currentUser = students.first;
    notifyListeners();
  }

  /// 로그아웃
  void logout() {
    currentUser = null;
    notifyListeners();
  }

  // ── 사람 찾기 ────────────────────────────────────────────

  /// uid로 사람 한 명 찾기. 없으면 null.
  AppUser? userByUid(String uid) {
    for (final u in _users) {
      if (u.uid == uid) return u;
    }
    return null;
  }

  /// 이름만 (없으면 '알 수 없음')
  String nameOf(String uid) => userByUid(uid)?.name ?? '알 수 없음';

  /// 좌석번호와 이름을 함께 (예: '12번 김민준')
  String labelOf(String uid) => userByUid(uid)?.displayLabel ?? '알 수 없음';

  /// 이름 또는 좌석번호로 학생 검색
  List<AppUser> searchStudents(String keyword) {
    final q = keyword.trim();
    if (q.isEmpty) return students;
    return students
        .where((s) =>
            s.name.contains(q) || (s.seatNumber?.toString() ?? '').contains(q))
        .toList();
  }

  // ── 벌점 ────────────────────────────────────────────────

  /// 학생 한 명의 벌점 내역 (최신이 위로)
  List<Penalty> penaltiesOf(String studentUid) =>
      _penalties.where((p) => p.studentUid == studentUid).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// 학생 한 명의 벌점 합계
  int totalPenaltyPoints(String studentUid) =>
      penaltiesOf(studentUid).fold(0, (sum, p) => sum + p.points);

  /// 오늘 부여된 벌점 건수
  int get todayPenaltyCount =>
      _penalties.where((p) => isSameDay(p.createdAt, DateTime.now())).length;

  /// 벌점 부여
  void addPenalty({
    required String studentUid,
    required String reason,
    required int points,
  }) {
    _penalties.add(Penalty(
      id: _newId('pen'),
      studentUid: studentUid,
      reason: reason,
      points: points,
      teacherName: currentUser?.name ?? '선생님',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  // ── 공지 ────────────────────────────────────────────────

  void addNotice({
    required String title,
    required String content,
    bool important = false,
  }) {
    _notices.add(Notice(
      id: _newId('not'),
      title: title,
      content: content,
      authorName: currentUser?.name ?? '선생님',
      createdAt: DateTime.now(),
      important: important,
    ));
    notifyListeners();
  }

  void updateNotice({
    required String id,
    required String title,
    required String content,
    required bool important,
  }) {
    for (final n in _notices) {
      if (n.id == id) {
        n.title = title;
        n.content = content;
        n.important = important;
        break;
      }
    }
    notifyListeners();
  }

  void deleteNotice(String id) {
    _notices.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // ── 도시락 ──────────────────────────────────────────────

  /// 이번 주 월~금 날짜 5개
  List<DateTime> get thisWeekDates => weekdaysOf(DateTime.now());

  /// 특정 날짜의 메뉴표. 없으면 null.
  LunchMenu? menuForDate(DateTime date) {
    for (final m in _lunchMenus) {
      if (isSameDay(m.date, date)) return m;
    }
    return null;
  }

  /// 특정 날짜의 신청 목록 (취소된 것 제외)
  List<LunchOrder> ordersForDate(DateTime date) =>
      _lunchOrders.where((o) => !o.cancelled && isSameDay(o.date, date)).toList();

  /// 특정 날짜의 메뉴별 신청 수. 예: {'제육덮밥': 7, '치킨마요덮밥': 4}
  Map<String, int> orderCountsForDate(DateTime date) {
    final counts = <String, int>{};
    for (final o in ordersForDate(date)) {
      counts[o.menuItem] = (counts[o.menuItem] ?? 0) + 1;
    }
    return counts;
  }

  /// 오늘 도시락 신청 수
  int get todayLunchOrderCount => ordersForDate(DateTime.now()).length;

  /// 메뉴 등록 (같은 날짜가 이미 있으면 덮어씁니다)
  void registerLunchMenu({
    required DateTime date,
    required List<String> menuItems,
    required DateTime deadline,
  }) {
    final existing = menuForDate(date);
    if (existing != null) {
      existing.menuItems = menuItems;
      existing.deadline = deadline;
    } else {
      _lunchMenus.add(LunchMenu(
        id: _newId('men'),
        date: dateOnly(date),
        menuItems: menuItems,
        deadline: deadline,
      ));
    }
    notifyListeners();
  }

  /// 해당 날짜 신청 마감
  void closeLunchDate(DateTime date) {
    final menu = menuForDate(date);
    if (menu != null) {
      menu.closed = true;
      notifyListeners();
    }
  }

  /// 학생 한 명의 도시락 신청 내역
  List<LunchOrder> lunchOrdersOf(String studentUid) =>
      _lunchOrders.where((o) => o.studentUid == studentUid).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── 질문 ────────────────────────────────────────────────

  /// 상태로 걸러낸 질문 목록. status가 null이면 전체.
  List<Question> questionsByStatus(QuestionStatus? status) => status == null
      ? questions
      : questions.where((q) => q.status == status).toList();

  /// 대기 중인 질문 수
  int get waitingQuestionCount =>
      _questions.where((q) => q.status == QuestionStatus.waiting).length;

  /// 학생 한 명의 질문 내역
  List<Question> questionsOf(String studentUid) =>
      questions.where((q) => q.studentUid == studentUid).toList();

  /// 질문 배정: 시간과 담당 선생님을 정하면 상태가 '배정'으로 바뀝니다.
  void assignQuestion({
    required String questionId,
    required DateTime assignedAt,
    required String teacherName,
  }) {
    for (final q in _questions) {
      if (q.id == questionId) {
        q.assignedAt = assignedAt;
        q.teacherName = teacherName;
        q.status = QuestionStatus.assigned;
        break;
      }
    }
    notifyListeners();
  }

  /// 질문 완료 처리
  void completeQuestion(String questionId) {
    for (final q in _questions) {
      if (q.id == questionId) {
        q.status = QuestionStatus.done;
        break;
      }
    }
    notifyListeners();
  }

  // ── 민원 ────────────────────────────────────────────────

  List<Complaint> complaintsByStatus(ComplaintStatus? status) => status == null
      ? complaints
      : complaints.where((c) => c.status == status).toList();

  /// 아직 완료되지 않은 민원 수
  int get openComplaintCount =>
      _complaints.where((c) => c.status != ComplaintStatus.done).length;

  /// 민원 상태 변경 (접수 → 처리중 → 완료)
  void updateComplaintStatus(String complaintId, ComplaintStatus status) {
    for (final c in _complaints) {
      if (c.id == complaintId) {
        c.status = status;
        break;
      }
    }
    notifyListeners();
  }

  /// 민원 답변 작성
  void replyToComplaint(String complaintId, String reply) {
    for (final c in _complaints) {
      if (c.id == complaintId) {
        c.reply = reply;
        c.repliedAt = DateTime.now();
        break;
      }
    }
    notifyListeners();
  }

  // ── 학생 계정 관리 ───────────────────────────────────────

  /// 학생 추가.
  /// 이메일은 3주차 Firebase 로그인 계정을 만들 때 쓰려고 받아 두기만 합니다.
  void addStudent({
    required String name,
    required int seatNumber,
    required String guardianPhone,
    required String email,
  }) {
    _users.add(AppUser(
      uid: _newId('u'),
      name: name,
      role: UserRole.student,
      seatNumber: seatNumber,
      phone: guardianPhone,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// 비밀번호 초기화. 지금은 흉내만 냅니다.
  /// 3주차에 Firebase Authentication의 비밀번호 재설정 메일 발송으로 바뀝니다.
  String resetPassword(String uid) {
    final user = userByUid(uid);
    return '${user?.name ?? '학생'} 계정의 비밀번호 초기화를 요청했습니다. '
        '(지금은 실제로 바뀌지 않습니다)';
  }

  // ── 처음 채워 넣는 가짜 자료 ─────────────────────────────
  void _seed() {
    final now = DateTime.now();
    final today = dateOnly(now);

    // 선생님 3명 (그중 한 명은 관리자)
    _users.addAll([
      AppUser(
        uid: 't1',
        name: '박선영',
        role: UserRole.teacher,
        phone: '010-2000-1001',
        createdAt: today.subtract(const Duration(days: 200)),
      ),
      AppUser(
        uid: 't2',
        name: '정우진',
        role: UserRole.teacher,
        phone: '010-2000-1002',
        createdAt: today.subtract(const Duration(days: 180)),
      ),
      AppUser(
        uid: 't3',
        name: '한지수',
        role: UserRole.admin,
        phone: '010-2000-1003',
        createdAt: today.subtract(const Duration(days: 300)),
      ),
    ]);

    // 학생 12명
    const studentNames = [
      '김민준',
      '이서연',
      '박도윤',
      '최지우',
      '정하은',
      '강시우',
      '조유진',
      '윤예준',
      '임채원',
      '오건우',
      '신수아',
      '배준호',
    ];
    for (var i = 0; i < studentNames.length; i++) {
      _users.add(AppUser(
        uid: 's${i + 1}',
        name: studentNames[i],
        role: UserRole.student,
        seatNumber: i + 1,
        phone: '010-1234-${two(i + 1)}${two(i + 1)}',
        createdAt: today.subtract(Duration(days: 120 - i * 3)),
      ));
    }

    // 공지 5개
    const noticeSeed = <List<Object>>[
      ['9월 모의고사 일정 안내', '9월 12일(토) 오전 9시부터 전 과목 모의고사를 실시합니다. 8시 40분까지 착석해 주세요.', true, 1],
      ['자습실 사용 규칙 재안내', '자습실 안에서는 휴대폰을 사용할 수 없습니다. 통화는 1층 로비에서 해 주세요.', false, 3],
      ['도시락 업체 변경 안내', '9월부터 도시락 업체가 변경됩니다. 주간 메뉴는 매주 월요일에 공지합니다.', false, 5],
      ['추석 연휴 휴원 안내', '9월 24일부터 26일까지 휴원합니다. 27일부터 정상 운영합니다.', true, 8],
      ['사물함 정리 요청', '이번 주 금요일까지 사물함을 정리해 주세요. 미정리 시 임의로 정리합니다.', false, 12],
    ];
    for (final row in noticeSeed) {
      final daysAgo = row[3] as int;
      _notices.add(Notice(
        id: _newId('not'),
        title: row[0] as String,
        content: row[1] as String,
        authorName: daysAgo.isEven ? '박선영' : '한지수',
        createdAt: now.subtract(Duration(days: daysAgo, hours: 2)),
        important: row[2] as bool,
      ));
    }

    // 벌점 15건
    const penaltySeed = <List<Object>>[
      ['s1', '지각', 2, 0],
      ['s3', '휴대폰 사용', 5, 0],
      ['s7', '자습 중 잡담', 3, 0],
      ['s2', '무단 외출', 5, 1],
      ['s5', '지각', 2, 1],
      ['s9', '자습실 취식', 3, 1],
      ['s4', '복장 불량', 1, 2],
      ['s11', '휴대폰 사용', 5, 2],
      ['s6', '지각', 2, 3],
      ['s8', '무단 결석', 10, 4],
      ['s1', '자습 중 잡담', 3, 5],
      ['s12', '지각', 2, 6],
      ['s10', '사물함 미정리', 1, 7],
      ['s3', '지각', 2, 9],
      ['s7', '휴대폰 사용', 5, 11],
    ];
    for (final row in penaltySeed) {
      final daysAgo = row[3] as int;
      _penalties.add(Penalty(
        id: _newId('pen'),
        studentUid: row[0] as String,
        reason: row[1] as String,
        points: row[2] as int,
        teacherName: daysAgo.isEven ? '박선영' : '정우진',
        createdAt: now.subtract(Duration(days: daysAgo, hours: 1)),
      ));
    }

    // 이번 주(월~금) 도시락 메뉴와 신청 내역
    final week = weekdaysOf(now);
    const weekMenus = <List<String>>[
      ['제육덮밥', '치킨마요덮밥'],
      ['돈까스', '김치찌개'],
      ['비빔밥', '유부초밥'],
      ['불고기덮밥', '카레라이스'],
      ['짜장밥', '순두부찌개'],
    ];
    for (var i = 0; i < week.length; i++) {
      final date = week[i];
      _lunchMenus.add(LunchMenu(
        id: _newId('men'),
        date: date,
        menuItems: weekMenus[i],
        deadline: DateTime(date.year, date.month, date.day, 10, 30),
        closed: date.isBefore(today),
      ));
      // 날짜마다 학생 8~10명이 신청한 것으로 꾸밉니다.
      final count = 8 + (i % 3);
      for (var j = 0; j < count; j++) {
        _lunchOrders.add(LunchOrder(
          id: _newId('ord'),
          date: date,
          studentUid: 's${j + 1}',
          menuItem: weekMenus[i][(i + j) % 2],
          orderedAt: DateTime(date.year, date.month, date.day, 9, 10 + j),
        ));
      }
    }

    // 질문 6건 (대기/배정/완료 섞음)
    _questions.addAll([
      Question(
        id: _newId('q'),
        studentUid: 's2',
        subject: '수학',
        content: '미적분 극한 단원 34번 문제 풀이가 이해되지 않습니다.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Question(
        id: _newId('q'),
        studentUid: 's5',
        subject: '영어',
        content: '독해 지문에서 관계대명사 생략이 헷갈립니다.',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Question(
        id: _newId('q'),
        studentUid: 's9',
        subject: '국어',
        content: '비문학 지문 시간 배분 방법을 상담하고 싶습니다.',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Question(
        id: _newId('q'),
        studentUid: 's1',
        subject: '수학',
        content: '확률과 통계 조건부확률 문제를 질문하고 싶습니다.',
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
        status: QuestionStatus.assigned,
        assignedAt: DateTime(today.year, today.month, today.day, 16),
        teacherName: '정우진',
      ),
      Question(
        id: _newId('q'),
        studentUid: 's7',
        subject: '과학',
        content: '물리 역학 단원 문제 풀이를 요청합니다.',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        status: QuestionStatus.assigned,
        assignedAt: DateTime(today.year, today.month, today.day, 17, 30),
        teacherName: '박선영',
      ),
      Question(
        id: _newId('q'),
        studentUid: 's4',
        subject: '영어',
        content: '어법 문제 오답 정리를 도와주세요.',
        createdAt: now.subtract(const Duration(days: 3)),
        status: QuestionStatus.done,
        assignedAt: now.subtract(const Duration(days: 2)),
        teacherName: '박선영',
      ),
    ]);

    // 민원 5건 (접수/처리중/완료 섞음)
    _complaints.addAll([
      Complaint(
        id: _newId('c'),
        studentUid: 's3',
        content: '3층 자습실 에어컨이 너무 춥습니다. 온도 조절 부탁드립니다.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Complaint(
        id: _newId('c'),
        studentUid: 's8',
        content: '남자 화장실 세면대 물이 잘 내려가지 않습니다.',
        createdAt: now.subtract(const Duration(hours: 20)),
      ),
      Complaint(
        id: _newId('c'),
        studentUid: 's6',
        content: '옆자리에서 계속 소리가 나서 집중이 어렵습니다.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        status: ComplaintStatus.inProgress,
      ),
      Complaint(
        id: _newId('c'),
        studentUid: 's11',
        content: '정수기 물이 미지근합니다. 점검 부탁드립니다.',
        createdAt: now.subtract(const Duration(days: 2)),
        status: ComplaintStatus.inProgress,
      ),
      Complaint(
        id: _newId('c'),
        studentUid: 's12',
        content: '도시락 수령 줄이 너무 길어 시간이 오래 걸립니다.',
        createdAt: now.subtract(const Duration(days: 4)),
        status: ComplaintStatus.done,
        reply: '수령 시간을 학년별로 나누어 안내했습니다. 이번 주부터 적용됩니다.',
        repliedAt: now.subtract(const Duration(days: 3)),
      ),
    ]);

    // 순찰 기록 몇 건 (11주차 QR 순찰 기능에서 실제로 쓰게 됩니다)
    _patrols.addAll([
      Patrol(
        id: _newId('pat'),
        studentUid: 's1',
        teacherName: '박선영',
        scannedAt: now.subtract(const Duration(hours: 1)),
        note: '3층 열람실',
      ),
      Patrol(
        id: _newId('pat'),
        studentUid: 's2',
        teacherName: '박선영',
        scannedAt: now.subtract(const Duration(hours: 1, minutes: 2)),
        note: '3층 열람실',
      ),
      Patrol(
        id: _newId('pat'),
        studentUid: 's5',
        teacherName: '정우진',
        scannedAt: now.subtract(const Duration(hours: 4)),
        note: '자리 비움',
      ),
    ]);
  }
}
