import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'home_screen.dart';

class IntroVideoScreen extends StatefulWidget {
  const IntroVideoScreen({Key? key}) : super(key: key);

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _isPlayingFirstVideo = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    // Initialize first video
    _controller1 = VideoPlayerController.asset('assets/videos/intro_part_1.mp4');
    await _controller1.initialize();
    
    // Initialize second video
    _controller2 = VideoPlayerController.asset('assets/videos/intro_part_2.mp4');
    await _controller2.initialize();

    setState(() {
      _isInitialized = true;
    });

    // Play first video
    _controller1.play();
    _controller1.addListener(_checkVideo1End);
  }

  void _checkVideo1End() {
    if (_controller1.value.position >= _controller1.value.duration) {
      _controller1.removeListener(_checkVideo1End);
      _playSecondVideo();
    }
  }

  void _playSecondVideo() {
    setState(() {
      _isPlayingFirstVideo = false;
    });
    _controller2.play();
    _controller2.addListener(_checkVideo2End);
  }

  void _checkVideo2End() {
    if (_controller2.value.position >= _controller2.value.duration) {
      _controller2.removeListener(_checkVideo2End);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: _isInitialized ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: AspectRatio(
            aspectRatio: _isPlayingFirstVideo 
                ? _controller1.value.aspectRatio 
                : _controller2.value.aspectRatio,
            child: VideoPlayer(_isPlayingFirstVideo ? _controller1 : _controller2),
          ),
        ),
      ),
    );
  }
}
