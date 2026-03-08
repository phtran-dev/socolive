class StreamInfo {
  final String flv;
  final String hdFlv;
  final String m3u8;
  final String hdM3u8;

  StreamInfo({
    required this.flv,
    required this.hdFlv,
    required this.m3u8,
    required this.hdM3u8,
  });

  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    String cleanUrl(String? url) {
      if (url == null) return '';
      return url.replaceAll('\\u003d', '=').replaceAll('\\u0026', '&');
    }

    return StreamInfo(
      flv: cleanUrl(json['flv']),
      hdFlv: cleanUrl(json['hdFlv']),
      m3u8: cleanUrl(json['m3u8']),
      hdM3u8: cleanUrl(json['hdM3u8']),
    );
  }

  String get bestUrl => hdM3u8.isNotEmpty ? hdM3u8 : m3u8;
  String get bestFlvUrl => hdFlv.isNotEmpty ? hdFlv : flv;
  bool get hasStream => m3u8.isNotEmpty || hdM3u8.isNotEmpty;
}

class RoomDetail {
  final String roomNum;
  final String title;
  final String streamerName;
  final StreamInfo stream;

  RoomDetail({
    required this.roomNum,
    required this.title,
    required this.streamerName,
    required this.stream,
  });

  factory RoomDetail.fromJson(Map<String, dynamic> json) {
    final room = json['room'] ?? {};
    final anchor = room['anchor'] ?? {};

    return RoomDetail(
      roomNum: room['roomNum']?.toString() ?? '',
      title: room['title'] ?? '',
      streamerName: anchor['nickName'] ?? 'Unknown',
      stream: StreamInfo.fromJson(json['stream'] ?? {}),
    );
  }
}
