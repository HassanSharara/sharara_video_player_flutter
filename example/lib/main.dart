

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

  late final ShararaVideoPlayerController controller;
  @override
  void initState() {
    controller = ShararaVideoPlayerController(playerController:
     VideoPlayerController.networkUrl(Uri.parse(
       "https://cdn.shabakaty.com/vascin18-mp4/0E5BAF9A-50C3-3FA1-51C1-B8B0D3ED34DB_video.mp4?response-content-disposition=attachment%3B%20filename%3D%22video.mp4%22&AWSAccessKeyId=PSFBSAZRKNBJOAMKHHBIBOBEONKBBOPKEDDBFBOJCH&Expires=1715742148&Signature=%2FSMwQ%2FdX2iPu3D%2Bw1N9MsLnXTss%3D"
     ))
    );
   controller.playerController.pause();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ShararaVideoPlayer(
      controller: controller,
    );
  }
}


