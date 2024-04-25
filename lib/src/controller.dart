
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class ShararaVideoPlayerController {

  /// VideoPlayerController .....
  final VideoPlayerController playerController;
  ShararaVideoPlayerController({
    required this.playerController
   });
  factory ShararaVideoPlayerController.networkUrl(final Uri uri){
    return ShararaVideoPlayerController(playerController: VideoPlayerController.networkUrl(uri));
  }
  factory ShararaVideoPlayerController.contentUri(final Uri uri){
    return ShararaVideoPlayerController(playerController: VideoPlayerController.contentUri(uri));
  }
  factory ShararaVideoPlayerController.asset(final String asset){
    return ShararaVideoPlayerController(playerController: VideoPlayerController.asset(asset));
  }
  factory ShararaVideoPlayerController.file(final File file){
    return ShararaVideoPlayerController(playerController: VideoPlayerController.file(file));
  }


   bool isFullScreen = false;
   bool isDisposed = false;
   double lastVolume = 80;
  final ValueNotifier<double> bottomPosition = ValueNotifier(0);

  /// Make Sure To Call Dispose Method After Disposing Your
  /// Whole Route
   void dispose(){
     isDisposed = true;
     Future.delayed(const Duration(seconds:4))
     .then((value) {
       bottomPosition.dispose();
     });
   }
}


extension PlayPause on ShararaVideoPlayerController {

  initialize()async{
   if(!playerController.value.isInitialized){
     await playerController.initialize();
   }
  }

  /// toggle meanse
  ///
  /// play video if it paused
  ///
  /// and pause it if it playing
  void toggle()async{
    if(playerController.value.isCompleted){
      await playerController.seekTo(const Duration());
      playerController.play();
      return;
    }
    if(playerController.value.isPlaying){
      pause();
    }else{
      play();
    }
  }

  /// playing the video
  void play(){
    _stateChecker(() async{
      playerController.play();
    });
  }

  /// pause the video
  void pause(){
    _stateChecker(() {
      playerController.pause();
    });
  }

  /// Mute => A shortcut for setting volume to 0.0 value
  void mute() {
    lastVolume = playerController.value.volume;
    setVolume(0);
  }

  /// setting the volume to the last volume before mute state
  void deMute() {
    setVolume(lastVolume);
  }

  /// Sets Volume Of Video
  ///
  /// Notice That The Maximum Volume Value is 1.0
  ///
  /// while The Lowest One is 0.0 (mute state)
  void setVolume(double volume){
    if(volume>=1){
      volume = 1;
    }else if (volume<=0){
      volume = 0;
    }
    _stateChecker(() => playerController.setVolume(volume));
  }

  /// Increase The volume by [value]
  void increaseVolumeBy( double value){
    setVolume(playerController.value.volume + value);
  }

  /// decrease The volume by [value]
  void decreaseVolumeBy( double value){
    setVolume(playerController.value.volume - value);
  }

  /// Seek to Custom Position
  void seekTo(final Duration position){
    _stateChecker(() => playerController.seekTo(position));
  }


  /// plusScrubbing and Skip some seconds of video
  void plusScrubbing(final int seconds){
    _stateChecker(() => playerController.seekTo(
        playerController.value.position + Duration(seconds:seconds)
    ));
  }

  /// minusScrubbing and Skip back some seconds of video
  void minusScrubbing(final int seconds){
    _stateChecker(() => playerController.seekTo(
        playerController.value.position - Duration(seconds:seconds)
    ));
  }

  /// Seek to Custom Position
  void setLooping(final bool value){
    _stateChecker(() => playerController.setLooping(value));
  }


  _stateChecker(Function() callBack){
    if(isDisposed)return;
    callBack();
  }
}