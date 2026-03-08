import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String streamer;

  const VideoPlayerScreen({
    super.key,
    required this.streamUrl,
    required this.title,
    required this.streamer,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  String? _error;
  bool _isPlaying = false;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    debugPrint('=== Video Player Screen ===');
    debugPrint('Stream URL: ${widget.streamUrl}');

    _player = Player();
    _controller = VideoController(_player);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _status = 'Loading stream...';
      _error = null;
    });

    try {
      await _player.open(
        Media(widget.streamUrl),
        play: true,
      );

      _player.stream.playing.listen((playing) {
        if (mounted) {
          setState(() {
            _isPlaying = playing;
            _status = playing ? 'Playing (audio only)' : 'Paused';
          });
        }
      });

      _player.stream.error.listen((error) {
        if (mounted && error != null && error.isNotEmpty) {
          setState(() {
            _error = error;
            _status = 'Error';
          });
        }
      });

      _player.stream.position.listen((position) {
        if (position.inMilliseconds > 0 && mounted && !_isPlaying) {
          setState(() {
            _isPlaying = true;
            _status = 'Playing (audio only)';
          });
        }
      });

      setState(() {
        _status = 'Stream loaded';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _status = 'Error';
        });
      }
    }
  }

  Future<void> _openInExternalPlayer() async {
    // Open in mpv
    try {
      await Process.start('mpv', [
        '--title=${widget.title}',
        widget.streamUrl,
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening in mpv...')),
        );
      }
    } catch (e) {
      // Fallback to VLC
      try {
        await Process.start('vlc', [widget.streamUrl]);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open external player: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${widget.title} - ${widget.streamer}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in external player',
            onPressed: _openInExternalPlayer,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _player.open(Media(widget.streamUrl), play: true);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // Video widget (may show blue due to GPU driver issues)
        Center(
          child: Video(
            controller: _controller,
            controls: MaterialVideoControls,
          ),
        ),
        // Info overlay
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Blue screen? GPU driver issue. Click 📺 to open in mpv/VLC',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Loading indicator
        if (!_isPlaying)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }
}
