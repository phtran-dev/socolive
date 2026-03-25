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
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String subCategoryName;
  final String hostName;
  final String guestName;
  final String hostIcon;
  final String guestIcon;
  final int matchTime;
  final int status;
  final bool isHot;
  final List<Anchor> anchors;

  Match({
    required this.scheduleId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.subCategoryName,
    required this.hostName,
    required this.guestName,
    required this.hostIcon,
    required this.guestIcon,
    required this.matchTime,
    required this.status,
    required this.isHot,
    required this.anchors,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      scheduleId: json['scheduleId']?.toString() ?? '',
      categoryId: json['categoryId'] is int ? json['categoryId'] : 0,
      categoryName: json['categoryName']?.toString() ?? '',
      categoryIcon: json['categoryIcon']?.toString() ?? '',
      subCategoryName: json['subCateName']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? 'TBD',
      guestName: json['guestName']?.toString() ?? 'TBD',
      hostIcon: json['hostIcon']?.toString() ?? '',
      guestIcon: json['guestIcon']?.toString() ?? '',
      matchTime: json['matchTime'] is int ? json['matchTime'] : 0,
      status: json['status'] is int ? json['status'] : 0,
      isHot: json['hot'] == '1' || json['hot'] == 1 || json['hot'] == true,
      anchors: (json['anchors'] as List<dynamic>?)
              ?.map((a) => Anchor.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get matchTitle => '$hostName vs $guestName';

  // Check if match is live (status 1 = live)
  bool get isLive => status == 1;
}

// Sport category model
class SportCategory {
  final int id;
  final String name;
  final String icon;
  final String iconAsset;

  const SportCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.iconAsset = '',
  });

  static const List<SportCategory> defaultCategories = [
    SportCategory(id: 0, name: 'Tất cả', icon: '', iconAsset: 'assets/icons/all.png'),
    SportCategory(id: 1, name: 'Bóng đá', icon: '', iconAsset: 'assets/icons/football.png'),
    SportCategory(id: 2, name: 'Bóng rổ', icon: '', iconAsset: 'assets/icons/basketball.png'),
    SportCategory(id: 3, name: 'Tennis', icon: '', iconAsset: 'assets/icons/tennis.png'),
    SportCategory(id: 4, name: 'Cầu lông', icon: '', iconAsset: 'assets/icons/badminton.png'),
    SportCategory(id: 5, name: 'Bóng chuyền', icon: '', iconAsset: 'assets/icons/volleyball.png'),
    SportCategory(id: 6, name: 'Bóng bàn', icon: '', iconAsset: 'assets/icons/table_tennis.png'),
    SportCategory(id: 7, name: 'Khác', icon: '', iconAsset: 'assets/icons/other.png'),
  ];
}

// Filter type enum
enum MatchFilter {
  all,      // Tất cả
  live,     // Trực tiếp
  hot,      // Hot
  today,    // Hôm nay
  tomorrow, // Ngày mai
}

extension MatchFilterExtension on MatchFilter {
  String get label {
    switch (this) {
      case MatchFilter.all:
        return 'TẤT CẢ';
      case MatchFilter.live:
        return 'TRỰC TIẾP';
      case MatchFilter.hot:
        return 'HOT';
      case MatchFilter.today:
        return 'NAY';
      case MatchFilter.tomorrow:
        return 'MAI';
    }
  }
}
