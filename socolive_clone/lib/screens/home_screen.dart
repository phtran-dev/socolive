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
        title: const Text('Socolive Clone'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDateSelector(context),
          Expanded(child: _buildMatchList(context)),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Consumer<MatchController>(
      builder: (context, controller, child) {
        final dateStr = DateFormat('EEEE, MMM d, y').format(controller.selectedDate);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.green[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: controller.isLoading ? null : controller.previousDay,
              ),
              GestureDetector(
                onTap: controller.isLoading ? null : controller.today,
                child: Column(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Tap for today',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: controller.isLoading ? null : controller.nextDay,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchList(BuildContext context) {
    return Consumer<MatchController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${controller.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadMatches(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.matches.isEmpty) {
          return const Center(
            child: Text('No matches available'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadMatches(),
          child: ListView.builder(
            itemCount: controller.matches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(context, controller.matches[index]);
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(match: match),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // League name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  match.subCategoryName.isNotEmpty
                      ? match.subCategoryName
                      : match.categoryName,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Teams
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamIcon(match.hostIcon),
                        const SizedBox(height: 8),
                        Text(
                          match.hostName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('VS', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamIcon(match.guestIcon),
                        const SizedBox(height: 8),
                        Text(
                          match.guestName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                    Icon(Icons.videocam, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${match.anchors.length} streamer${match.anchors.length > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.green[700]),
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_soccer, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.network(
        url,
        width: 50,
        height: 50,
        errorBuilder: (_, __, ___) => Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.sports_soccer, color: Colors.grey),
        ),
      ),
    );
  }
}
