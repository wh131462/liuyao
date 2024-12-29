import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;
  final bool autoPlay;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.isLocal = false,
    this.autoPlay = true,
    this.showControls = true,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _controlsVisible = true;
  bool _isInitialized = false;
  bool _hasError = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isLocal) {
      _checkAsset().then((_) => _initializePlayer());
    } else {
      _initializePlayer();
    }
  }

  Future<void> _checkAsset() async {
    try {
      await rootBundle.load(widget.videoUrl);
      print('Asset exists: ${widget.videoUrl}');
    } catch (e) {
      print('Asset not found: ${widget.videoUrl}');
      print('Error: $e');
    }
  }

  Future<void> _initializePlayer() async {
    try {
      print('Attempting to load video: ${widget.videoUrl}');
      _controller = widget.isLocal
          ? VideoPlayerController.asset(widget.videoUrl)
          : VideoPlayerController.network(widget.videoUrl);

      print('Controller created, initializing...');
      await _controller.initialize();
      print('Controller initialized');

      _controller.addListener(_videoListener);
      
      if (widget.autoPlay) {
        await _controller.play();
        _isPlaying = true;
      }

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      print('Video initialization error: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        _hasError = true;
      });
    }
  }

  void _videoListener() {
    if (_controller.value.hasError) {
      setState(() {
        _hasError = true;
      });
    }
    
    // 视频播放完成时的处理
    if (_controller.value.position >= _controller.value.duration) {
      setState(() {
        _isPlaying = false;
        _controlsVisible = true;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });

    // 自动隐藏控制栏
    if (_controlsVisible && _isPlaying) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _controlsVisible = true;
      } else {
        _controller.play();
        _isPlaying = true;
        _startHideTimer();
      }
    });
  }

  void _startHideTimer() {
    if (!widget.showControls) return;
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('视频加载失败'),
            const SizedBox(height: 8),
            Text(
              '请确保视频文件存在于正确位置\n${widget.videoUrl}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _initializePlayer,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (_controlsVisible && widget.showControls)
            _buildControls(),
          if (!_isPlaying && _controlsVisible)
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 50,
                icon: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
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
          stops: [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopBar(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.fullscreen, color: Colors.white),
          onPressed: () => _goFullScreen(context),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  Text(
                    '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _controller.setVolume(_controller.value.volume > 0 ? 0 : 1);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      _controller,
      allowScrubbing: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      colors: const VideoProgressColors(
        playedColor: Colors.red,
        bufferedColor: Colors.grey,
        backgroundColor: Colors.black45,
      ),
    );
  }

  void _goFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          controller: _controller,
          onClose: () {
            Navigator.pop(context);
            _startHideTimer();
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }
}

// 全屏播放器组件
class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onClose;

  const FullScreenVideoPlayer({
    Key? key,
    required this.controller,
    required this.onClose,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _startHideTimer();
  }

  void _startHideTimer() {
    if (widget.controller.value.isPlaying) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _controlsVisible = !_controlsVisible;
          });
          _startHideTimer();
        },
        onDoubleTap: () {
          setState(() {
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
              _startHideTimer();
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            if (_controlsVisible)
              _buildFullScreenControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenControls() {
    // 复用之前的控制栏代码，但添加返回按钮
    return Container(
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
          stops: [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onClose,
            ),
          ),
          // 其他控制元素...
        ],
      ),
    );
  }
}
