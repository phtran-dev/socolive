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
    return Anchor(
      uid: json['uid']?.toString() ?? '',
      nickName: json['nickName'] ?? 'Unknown',
      icon: json['icon'] ?? '',
      roomNum: json['anchor']?['roomNum']?.toString() ?? json['uid']?.toString() ?? '',
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
      categoryName: json['categoryName'] ?? '',
      subCategoryName: json['subCateName'] ?? '',
      hostName: json['hostName'] ?? 'TBD',
      guestName: json['guestName'] ?? 'TBD',
      hostIcon: json['hostIcon'] ?? '',
      guestIcon: json['guestIcon'] ?? '',
      matchTime: json['matchTime'] ?? 0,
      anchors: (json['anchors'] as List<dynamic>?)
              ?.map((a) => Anchor.fromJson(a))
              .toList() ??
          [],
    );
  }

  String get matchTitle => '$hostName vs $guestName';
}
