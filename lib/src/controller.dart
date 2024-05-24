
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShararaVideoPlayerController {

  final List<ViewModeDimensions> dimensions = [
    ...ViewModeDimensions.defaultDimensions
  ];
  static ViewModeDimensions? _dimension;
  late final ValueNotifier<ViewModeDimensions?> viewMode;
  /// VideoPlayerController .....
  final VideoPlayerController playerController;
  ShararaVideoPlayerController({
    required this.playerController,
    this.autoDisposeVideoPlayerController = false,
   }){
    viewMode = ValueNotifier(_dimension);
  }
  bool autoDisposeVideoPlayerController = false ;
  factory ShararaVideoPlayerController.networkUrl(final Uri uri){
    return ShararaVideoPlayerController(
        playerController: VideoPlayerController.networkUrl(uri),
        autoDisposeVideoPlayerController:true
    );
  }

  factory ShararaVideoPlayerController.contentUri(final Uri uri){
    return ShararaVideoPlayerController(
        playerController: VideoPlayerController.contentUri(uri),
        autoDisposeVideoPlayerController:true,
    );
  }

  factory ShararaVideoPlayerController.asset(final String asset){
    return ShararaVideoPlayerController(
        playerController: VideoPlayerController.asset(asset),
        autoDisposeVideoPlayerController:true
    );
  }

  factory ShararaVideoPlayerController.file(final File file){
    return ShararaVideoPlayerController(
        playerController: VideoPlayerController.file(file),
        autoDisposeVideoPlayerController:true
    );
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
       viewMode.dispose();
       if(autoDisposeVideoPlayerController){
         playerController.dispose();
       }
     });
   }
}


extension UiWorker on ShararaVideoPlayerController {
  /// setting default dimension before initializing controller
  setDefaultDimension(ViewModeDimensions? dimension){
    ShararaVideoPlayerController._dimension = dimension;
  }

  setDimension(ViewModeDimensions? dimension){
    setDefaultDimension(dimension);
    viewMode.value = dimension;
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
      play();
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
    if(playerController.value.isPlaying)return;
    _stateChecker(() async{
      playerController.play();
    });
  }

  /// pause the video
  void pause(){
    if(!playerController.value.isPlaying)return;
    _stateChecker(() {
      playerController.pause();
    });
  }

  /// Mute => A shortcut for setting volume to 0.0 value
  void mute() {
    final double volume = playerController.value.volume;
    if(volume>=0.1){
      lastVolume = volume;
    }
    setVolume(0);
  }

  /// setting the volume to the last volume before mute state
  void deMute() {
    if(lastVolume<=0.09){
      lastVolume = 0.1;
    }
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
    Future.delayed(const Duration(milliseconds:40));
    callBack();
  }
}


class ViewModeDimensions {
  final Widget? icon;
  final String? hint;
  final double? aspectRatio;
  const ViewModeDimensions._({
    this.icon,
    this.hint,
    required this.aspectRatio});
  static const ViewModeDimensions fitScreen =     ViewModeDimensions._(hint:"FS", aspectRatio: null);
  static const ViewModeDimensions cri =     ViewModeDimensions._(hint: "CRI", aspectRatio: 1);
  static const ViewModeDimensions oneTo3 =     ViewModeDimensions._(hint: "1:3", aspectRatio: 1/3);
  static const ViewModeDimensions threeTo2 =     ViewModeDimensions._(hint: "3:2", aspectRatio: 3/2);
  static const ViewModeDimensions oneTo1 =     ViewModeDimensions._(hint: "1:1", aspectRatio: 1/1);

  static const ViewModeDimensions half =
      ViewModeDimensions._(aspectRatio: 2/1,icon:Icon(Icons.ad_units_outlined));
  static const List<ViewModeDimensions> defaultDimensions = [
    fitScreen,
    cri,
    oneTo3,
    threeTo2,
    oneTo1,
  ];
}