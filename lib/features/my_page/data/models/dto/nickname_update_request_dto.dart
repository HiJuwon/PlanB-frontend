// PATCH /api/v1/user/nickname 요청 body

class NicknameUpdateRequestDto {
  const NicknameUpdateRequestDto({required this.nickname});

  final String nickname;

  static const int maxLength = 10;  // 최대 10자 제한.

  // - 한글(완성형) + 공백만 쓸 수 있음
  // - 공백으로 시작 X
  // - 연속 공백 X
  static final RegExp _pattern = RegExp(r'^(?=\S)(?!.*\s{2})[가-힣\s]+$');

  /// 서버로 보내기 전 검사 (문제 없으면 null, 있으면 사용자에게 보여줄 메시지 노출)
  static String? validate(String nickname) {
    if (nickname.isEmpty) return '이름을 입력해주세요';
    if (nickname.length > maxLength) return '이름은 $maxLength자 이하로 입력해주세요';
    if (!_pattern.hasMatch(nickname)) return '이름은 한글로만 입력해주세요';
    return null;
  }

  Map<String, dynamic> toJson() => {'nickname': nickname};
}