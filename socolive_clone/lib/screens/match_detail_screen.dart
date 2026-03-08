import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match.dart';
import '../models/stream.dart';
import '../services/api_service.dart';
import 'video_player_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final ApiService _api = ApiService();
  final Map<String, RoomDetail> _roomDetails = {};
  final Set<String> _loading = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllStreams();
  }

  Future<void> _loadAllStreams() async {
    for (final anchor in widget.match.anchors) {
      if (!_loading.contains(anchor.roomNum)) {
        setState(() => _loading.add(anchor.roomNum));

        try {
          final detail = await _api.getRoomDetail(anchor.roomNum);
          if (mounted) {
            setState(() {
              _roomDetails[anchor.roomNum] = detail;
              _loading.remove(anchor.roomNum);
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() => _loading.remove(anchor.roomNum));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.subCategoryName),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildMatchHeader(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Available Streams',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(child: _buildStreamersList()),
        ],
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTeamIcon(widget.match.hostIcon),
                const SizedBox(height: 8),
                Text(
                  widget.match.hostName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Text('VS', style: TextStyle(fontSize: 18, color: Colors.grey)),
          Expanded(
            child: Column(
              children: [
                _buildTeamIcon(widget.match.guestIcon),
                const SizedBox(height: 8),
                Text(
                  widget.match.guestName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamIcon(String url) {
    if (url.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_soccer, size: 30, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider),
        ),
      ),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_soccer, color: Colors.grey),
      ),
    );
  }

  Widget _buildStreamersList() {
    if (widget.match.anchors.isEmpty) {
      return const Center(
        child: Text('No streams available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: widget.match.anchors.length,
      itemBuilder: (context, index) {
        final anchor = widget.match.anchors[index];
        final detail = _roomDetails[anchor.roomNum];
        final isLoading = _loading.contains(anchor.roomNum);

        return _buildStreamerCard(anchor, detail, isLoading);
      },
    );
  }

  Widget _buildStreamerCard(Anchor anchor, RoomDetail? detail, bool isLoading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: anchor.icon.isNotEmpty ? NetworkImage(anchor.icon) : null,
          child: anchor.icon.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(anchor.nickName),
        subtitle: isLoading
            ? const Text('Loading stream...')
            : detail != null && detail.stream.hasStream
                ? Text('Room: ${anchor.roomNum}')
                : const Text('Stream not available'),
        trailing: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : detail != null && detail.stream.hasStream
                ? IconButton(
                    icon: const Icon(Icons.play_circle_fill),
                    color: Colors.green,
                    iconSize: 40,
                    onPressed: () async {
                      // Fetch fresh stream URL before playing
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        final freshDetail = await _api.getRoomDetail(anchor.roomNum);
                        Navigator.pop(context); // Close loading dialog

                        if (freshDetail.stream.hasStream) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                streamUrl: freshDetail.stream.bestUrl,
                                title: widget.match.matchTitle,
                                streamer: anchor.nickName,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Stream not available')),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  )
                : const Icon(Icons.videocam_off, color: Colors.grey),
      ),
    );
  }
}
