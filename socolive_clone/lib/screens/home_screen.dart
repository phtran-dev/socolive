import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/match_controller.dart';
import '../models/match.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Socolive'),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1a472a),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MatchController>().loadMatches(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a472a),
              const Color(0xFF0d2818),
              Colors.grey[900]!,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildSportCategories(context),
            _buildFilterTabs(context),
            _buildDateSelector(context),
            Expanded(child: _buildMatchList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSportCategories(BuildContext context) {
    return Consumer<MatchController>(
      builder: (context, controller, child) {
        final categories = controller.availableCategories;

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = controller.selectedCategoryId == category.id;

              return GestureDetector(
                onTap: () => controller.setCategory(category.id),
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green[600] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.green[400]!, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCategoryIcon(category.id, isSelected),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(int categoryId, bool isSelected) {
    IconData iconData;
    switch (categoryId) {
      case 0:
        iconData = Icons.apps;
        break;
      case 1:
        iconData = Icons.sports_soccer;
        break;
      case 2:
        iconData = Icons.sports_basketball;
        break;
      case 3:
        iconData = Icons.sports_tennis;
        break;
      case 4:
        iconData = Icons.sports_baseball; // Badminton
        break;
      case 5:
        iconData = Icons.sports_volleyball;
        break;
      case 6:
        iconData = Icons.sports_baseball; // Table tennis
        break;
      default:
        iconData = Icons.sports;
    }

    return Icon(
      iconData,
      color: isSelected ? Colors.white : Colors.grey[400],
      size: 24,
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Consumer<MatchController>(
      builder: (context, controller, child) {
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: MatchFilter.values.map((filter) {
              final isSelected = controller.selectedFilter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setFilter(filter),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[600] : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green[600]! : Colors.grey[600]!,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (filter == MatchFilter.live)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (filter == MatchFilter.hot)
                            Icon(
                              Icons.local_fire_department,
                              color: isSelected ? Colors.white : Colors.orange,
                              size: 14,
                            ),
                          if (filter == MatchFilter.hot)
                            const SizedBox(width: 2),
                          Text(
                            filter.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Consumer<MatchController>(
      builder: (context, controller, child) {
        final dateStr = DateFormat('EEEE, d MMM').format(controller.selectedDate);
        final isToday = _isSameDay(controller.selectedDate, DateTime.now());

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.grey[400]),
                onPressed: controller.isLoading ? null : controller.previousDay,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: controller.isLoading ? null : controller.today,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.green[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isToday ? 'Hôm nay - $dateStr' : dateStr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: Colors.grey[400]),
                onPressed: controller.isLoading ? null : controller.nextDay,
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildMatchList(BuildContext context) {
    return Consumer<MatchController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (controller.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi kết nối',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error!,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadMatches(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final matches = controller.matches;

        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Không có trận đấu',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.green,
          onRefresh: () => controller.loadMatches(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(context, matches[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match) {
    final time = DateTime.fromMillisecondsSinceEpoch(match.matchTime);
    final timeStr = DateFormat.Hm().format(time);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: match.isLive
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(match: match),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header with league and status
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        match.subCategoryName.isNotEmpty
                            ? match.subCategoryName
                            : match.categoryName,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (match.isHot && !match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            'HOT',
                            style: TextStyle(
                              color: Colors.orange[200],
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamIcon(match.hostIcon),
                        const SizedBox(height: 6),
                        Text(
                          match.hostName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'VS',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamIcon(match.guestIcon),
                        const SizedBox(height: 6),
                        Text(
                          match.guestName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Streamers count
              if (match.anchors.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 14, color: Colors.green[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${match.anchors.length} streamer${match.anchors.length > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.green[400], fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamIcon(String url) {
    if (url.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.sports_soccer, color: Colors.grey[500], size: 24),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[700],
          child: Icon(Icons.sports_soccer, color: Colors.grey[500], size: 24),
        ),
      ),
    );
  }
}
