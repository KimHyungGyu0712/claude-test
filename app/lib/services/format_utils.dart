// 이 파일은 날짜와 시간을 화면에 보기 좋은 한글 글자로 바꿔 주는 도우미 함수 모음입니다.
// 외부 라이브러리(intl 등)를 쓰지 않고 직접 간단하게 만들었습니다.
// 예: 2026-09-05 14:30 -> '2026-09-05', '9월 5일 (토)', '14:30'

/// 숫자를 두 자리로 맞춰 줍니다. 예: 5 -> '05'
String two(int n) => n.toString().padLeft(2, '0');

/// '2026-09-05' 모양
String formatDate(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

/// '14:30' 모양
String formatTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

/// '2026-09-05 14:30' 모양
String formatDateTime(DateTime d) => '${formatDate(d)} ${formatTime(d)}';

/// 요일 한 글자. 1(월)~7(일)
String weekdayLabel(DateTime d) {
  const labels = ['월', '화', '수', '목', '금', '토', '일'];
  return labels[d.weekday - 1];
}

/// '9월 5일 (토)' 모양
String formatDateKorean(DateTime d) =>
    '${d.month}월 ${d.day}일 (${weekdayLabel(d)})';

/// 시/분/초를 0으로 지운 "날짜만" 값을 돌려줍니다.
/// 날짜끼리 비교할 때 시간 때문에 틀리는 것을 막아 줍니다.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 두 날짜가 같은 날인지 확인합니다.
bool isSameDay(DateTime a, DateTime b) => dateOnly(a) == dateOnly(b);

/// 이번 주 월요일부터 금요일까지 5일치 날짜를 만들어 줍니다.
List<DateTime> weekdaysOf(DateTime day) {
  final monday = dateOnly(day).subtract(Duration(days: day.weekday - 1));
  return List<DateTime>.generate(5, (i) => monday.add(Duration(days: i)));
}
