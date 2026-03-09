class Anchor {
  final String uid;
  final String nickName;
  final String icon;
  final String roomNum;

  Anchor({
    required this.uid,
    required this.nickName,
    required this.icon,
    required this.roomNum,
  });

  factory Anchor.fromJson(Map<String, dynamic> json) {
    // roomNum can be in anchor.roomNum or directly as uid
    String roomNum = '';
    if (json['anchor'] != null && json['anchor']['roomNum'] != null) {
      roomNum = json['anchor']['roomNum'].toString();
    } else if (json['uid'] != null) {
      roomNum = json['uid'].toString();
    }

    return Anchor(
      uid: json['uid']?.toString() ?? '',
      nickName: json['nickName']?.toString() ?? 'Unknown',
      icon: json['icon']?.toString() ?? '',
      roomNum: roomNum,
    );
  }
}

class Match {
  final String scheduleId;
  final String categoryName;
  final String subCategoryName;
  final String hostName;
  final String guestName;
  final String hostIcon;
  final String guestIcon;
  final int matchTime;
  final List<Anchor> anchors;

  Match({
    required this.scheduleId,
    required this.categoryName,
    required this.subCategoryName,
    required this.hostName,
    required this.guestName,
    required this.hostIcon,
    required this.guestIcon,
    required this.matchTime,
    required this.anchors,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      scheduleId: json['scheduleId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      subCategoryName: json['subCateName']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? 'TBD',
      guestName: json['guestName']?.toString() ?? 'TBD',
      hostIcon: json['hostIcon']?.toString() ?? '',
      guestIcon: json['guestIcon']?.toString() ?? '',
      matchTime: json['matchTime'] is int ? json['matchTime'] : 0,
      anchors: (json['anchors'] as List<dynamic>?)
              ?.map((a) => Anchor.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get matchTitle => '$hostName vs $guestName';
}
