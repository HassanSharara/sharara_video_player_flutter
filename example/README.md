# Sharara Video Player

Sharara Video Player is a video player for flutter that provide basic fundamentals for use for developers
is also powerful and easy on use
# Features

- Double tap to seek video (LeftCorner , RightCorner).
- Controls View Actions to  perform any action on video.
- Very Fast With Powerful play handles.
- Easy to Use.
- Smart Dispose Handle to Prevent Framework Exceptions.
- not effecting on any overlay or outer context layer.
- Custom animations.
- Custom controls for normal and fullscreen.
- Auto hide controls.


### Installation

Add the following dependencies in your pubspec.yaml file of your flutter project.

```flutter
    sharara_video_player: <latest_version>
    video_player: <latest_version>
```
or you can use terminal command
```terminal command 
   flutter pub add sharara_video_player
   flutter pub add video_player
```

### How to use

Create a `ShararaVideoPlayerController` and pass the controller to `ShararaVideoPlayer`,
make sure to dispose `ShararaVideoPlayer` after disposing the current screen.

```dart


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
    controller = ShararaVideoPlayerController(playerController:  VideoPlayerController
        .networkUrl(Uri.parse("your_custom_url")));
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





```
