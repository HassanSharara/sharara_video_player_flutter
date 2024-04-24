

import 'package:flutter/material.dart';
import 'package:sharara_video_player/video_player_sharara.dart';
import 'package:video_player/video_player.dart';

main(){
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:Scaffold(
        body:VideoPlayer(),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});
  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {

  final VideoPlayerController controller1 = VideoPlayerController
 .networkUrl(Uri.parse("your_custom_url"));
  late final ShararaVideoPlayerController controller;
  @override
  void initState() {
    controller = ShararaVideoPlayerController(playerController: controller1);
   controller.playerController.pause();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ShararaVideoPlayer(
        controller: controller
    );
  }
}


