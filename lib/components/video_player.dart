import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // 用于控制系统UI

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl; // 视频地址
  final bool isLocal;    // 是否是本地视频

  VideoPlayerWidget({required this.videoUrl, this.isLocal = false});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _controlsVisible = true; // 控制按钮是否可见

  @override
  void initState() {
    super.initState();
    // 根据传入的参数选择加载方式
    if (widget.isLocal) {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.network(widget.videoUrl);
    }

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _isPlaying = true;
    });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
      // 点击视频时显示/隐藏控制按钮
      onTap: () {
        setState(() {
          _controlsVisible = !_controlsVisible;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio, // 保持视频的宽高比
            child: VideoPlayer(_controller),
          ),
          // 如果控制按钮可见，则显示控件层
          if (_controlsVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildControls(context), // 构建视频控制按钮
            ),
        ],
      ),
    )
        : Center(
      child: CircularProgressIndicator(), // 视频加载时显示进度指示器
    );
  }

  Widget _buildControls(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch, // 确保进度条宽度充满
      children: [
        _buildProgressBar(), // 进度条
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _togglePlayPause,
            ),
            Text(
              _formatDuration(_controller.value.position) +
                  ' / ' +
                  _formatDuration(_controller.value.duration),
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: Icon(
                _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: _toggleMute,
            ),
            IconButton(
              icon: Icon(
                Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () {
                _goFullScreen(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 切换播放/暂停
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  // 切换静音
  void _toggleMute() {
    setState(() {
      _controller.setVolume(_controller.value.volume > 0 ? 0 : 1);
    });
  }

  // 跳转到全屏页面
  void _goFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          controller: _controller,
        ),
      ),
    );
  }

  // 视频进度条
  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      _controller,
      allowScrubbing: true, // 允许拖动进度条
      colors: VideoProgressColors(
        playedColor: Colors.red, // 已播放部分的颜色
        bufferedColor: Colors.grey, // 缓冲部分的颜色
        backgroundColor: Colors.black, // 背景颜色
      ),
    );
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// 全屏播放器组件
class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  FullScreenVideoPlayer({required this.controller});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    // 进入全屏模式并强制横屏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // 退出时恢复竖屏和系统UI
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            if (_controlsVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildFullScreenControls(context),
              ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenControls(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Colors.red,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
              IconButton(
                icon: Icon(
                  widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  });
                },
              ),
              Text(
                _formatDuration(widget.controller.value.position) +
                    ' / ' +
                    _formatDuration(widget.controller.value.duration),
                style: TextStyle(color: Colors.white),
              ),
            ],),
            Row(children: [
              IconButton(
                icon: Icon(
                  widget.controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.setVolume(widget.controller.value.volume > 0 ? 0 : 1);
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],)
          ],
        ),
      ],
    );
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
