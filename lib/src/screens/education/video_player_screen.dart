/// Video Player Screen - Story 3.11
/// 
/// Full-screen video player for educational videos.
/// AC3: Video Playback Experience
/// AC5: Voice Narration (Accessibility)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/education_models.dart';
import '../../services/education_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final EducationalContent content;
  final int farmerId;
  final String? authToken;
  
  const VideoPlayerScreen({
    super.key,
    required this.content,
    required this.farmerId,
    this.authToken,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final EducationService _service;
  
  // Playback state
  bool _isPlaying = false;
  double _progress = 0.0;
  double _playbackSpeed = 1.0;
  bool _showControls = true;
  bool _isCaptionsEnabled = false;
  bool _isFullscreen = false;
  
  // Progress tracking
  int _lastTrackedProgress = 0;

  @override
  void initState() {
    super.initState();
    _service = EducationService(
      farmerId: widget.farmerId,
      authToken: widget.authToken,
    );
    
    // Start from previous progress if resuming
    _progress = widget.content.viewProgress / 100.0;
    
    // Show resume prompt if progress > 10%
    if (widget.content.viewProgress > 10 && widget.content.viewProgress < 90) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResumeDialog();
      });
    }
  }

  @override
  void dispose() {
    // Track final progress on exit
    _trackProgress(force: true);
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _showResumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue watching?'),
        content: Text(
          'You left off at ${widget.content.viewProgress}%. Resume from there?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _progress = 0.0);
            },
            child: const Text('Start Over'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Keep current progress
            },
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    
    // In real implementation, control video player here
    if (_isPlaying) {
      // Start or resume playback
      _simulatePlayback();
    }
  }

  void _simulatePlayback() {
    // Simulate video progress for demo
    // In real implementation, use video_player or youtube_player_flutter
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isPlaying && _progress < 1.0) {
        setState(() {
          _progress += 0.01; // Increment progress
        });
        _trackProgress();
        _simulatePlayback();
      }
    });
  }

  void _onSeek(double value) {
    setState(() => _progress = value);
    _trackProgress(force: true);
  }

  void _changePlaybackSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 0.5;
      } else {
        _playbackSpeed = 1.0;
      }
    });
  }

  void _toggleCaptions() {
    setState(() => _isCaptionsEnabled = !_isCaptionsEnabled);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _trackProgress({bool force = false}) async {
    final currentProgress = (_progress * 100).round();
    
    // Only track if progress changed by at least 5%
    if (force || (currentProgress - _lastTrackedProgress).abs() >= 5) {
      _lastTrackedProgress = currentProgress;
      
      try {
        await _service.trackView(widget.content.id, currentProgress);
      } catch (e) {
        // Silently fail - not critical
      }
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSeconds = widget.content.durationSeconds ?? 180;
    final currentSeconds = (_progress * totalSeconds).round();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video placeholder (would be actual video player)
            _buildVideoPlaceholder(theme),
            
            // Controls overlay
            if (_showControls) ...[
              // Gradient overlay for controls visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
              
              // Top bar
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        iconSize: 28,
                      ),
                      Expanded(
                        child: Text(
                          widget.content.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Captions toggle
                      IconButton(
                        icon: Icon(
                          _isCaptionsEnabled 
                              ? Icons.closed_caption 
                              : Icons.closed_caption_off,
                          color: Colors.white,
                        ),
                        onPressed: _toggleCaptions,
                        tooltip: 'Captions',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Center play/pause button
              Center(
                child: Material(
                  color: Colors.black38,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _togglePlayPause,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 56, // Large touch target (AC5)
                        semanticLabel: _isPlaying ? 'Pause' : 'Play',
                      ),
                    ),
                  ),
                ),
              ),
              
              // Bottom controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: theme.colorScheme.primary,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: theme.colorScheme.primary,
                            overlayColor: theme.colorScheme.primary.withOpacity(0.3),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _progress.clamp(0.0, 1.0),
                            onChanged: _onSeek,
                            semanticFormatterCallback: (value) => 
                                '${(value * 100).round()}%',
                          ),
                        ),
                        
                        // Time and controls row
                        Row(
                          children: [
                            // Current time / Total time
                            Text(
                              '${_formatDuration(currentSeconds)} / ${_formatDuration(totalSeconds)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Playback speed
                            TextButton(
                              onPressed: _changePlaybackSpeed,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 48),
                              ),
                              child: Text('${_playbackSpeed}x'),
                            ),
                            
                            // Fullscreen toggle
                            IconButton(
                              icon: Icon(
                                _isFullscreen 
                                    ? Icons.fullscreen_exit 
                                    : Icons.fullscreen,
                                color: Colors.white,
                              ),
                              onPressed: _toggleFullscreen,
                              tooltip: _isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Captions display
              if (_isCaptionsEnabled)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Sample caption text would appear here',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(ThemeData theme) {
    // In production, this would be replaced with actual video player
    // Using video_player, youtube_player_flutter, or chewie package
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thumbnail as placeholder
            if (widget.content.thumbnailUrl.isNotEmpty)
              Image.network(
                widget.content.thumbnailUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.video_library,
                  size: 64,
                  color: Colors.white30,
                ),
              )
            else
              Icon(
                Icons.play_circle_outline,
                size: 120,
                color: Colors.white30,
              ),
            const SizedBox(height: 16),
            Text(
              'Video Player Placeholder',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Integration with youtube_player_flutter or video_player\nwill replace this placeholder',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
