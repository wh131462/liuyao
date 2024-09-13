import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/logger.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl; // 视频地址
  final bool isLocal;    // 是否是本地视频

  VideoPlayerWidget({required this.videoUrl, this.isLocal = false});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 根据传入的参数选择加载方式
    if (widget.isLocal) {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.dataFromString(widget.videoUrl));
    }

    _controller.initialize().then((_) {
      setState(() {}); // 视频加载完成后刷新界面
      _controller.play(); // 自动播放视频
      logger.info("视频播放 ${widget.videoUrl}");
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
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio, // 保持视频的宽高比
      child: VideoPlayer(_controller),
    )
        : Center(
      child: CircularProgressIndicator(), // 视频加载时显示进度指示器
    );
  }
}
