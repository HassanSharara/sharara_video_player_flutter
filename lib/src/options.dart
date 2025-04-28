

 import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

final class Options {

   factory Options.generate() => const Options();

   const Options({    this.bottomActionsBarHeight,
     this.bottomActionsBarColor,
     this.bottomActionsBarBackgroundColor,
     this.actionBuilder,
     this.height,
     this.onNavigate,
     this.stackChildren,
     this.width,
     this.addReloadOptionWhenFailed,
     this.reloadTitle = "reload",
     this.autoInitialize = true,
     this.withPopIcon = false,
     this.applyOrientationsEnforcement = true,
     this.convexMirror = false,
     this.autoLoop = false,
     this.showTopVolumeController = true,
     this.autoPauseAfterDispose = true,
     this.showViewModes = false,
     this.showViewModesOnlyWithFullScreen = true,
     this.bottomActionsBarSize = 28,
     this.bigIconsSize = 35,});
   /// just to fit the lang of your app
   final String reloadTitle;
   /// auto buffering the video
   final bool autoInitialize ;

   /// when file or stream failed to load data add reload button with sending new video player controller
   final  Function(VideoPlayerController)? addReloadOptionWhenFailed;
   /// this option will force the view port and the Preferred Orientations to be the same as the video Orientations
   final bool applyOrientationsEnforcement ;

   /// auto looping the video
   final bool autoLoop ;
   /// options about how to view video
   final bool showViewModes ;

   /// show view mode only when screen is full
   final bool showViewModesOnlyWithFullScreen ;


   /// you can call this function if you specified custom navigator in your app
   final Function(Widget)? onNavigate;
   /// The Width And Height of Video Player Must Be Fit With Icons Size
   ///
   /// [bottomActionsBarSize]
   final double? height,width;
   /// sets the height of bottom actions bar
   final double? bottomActionsBarHeight;
   /// set the color of bottom actions bar
   final Color? bottomActionsBarColor,bottomActionsBarBackgroundColor;

   /// set the Size of bottom actions bar
   ///
   /// notice That you need to scale [bottomActionsBarSize] with it to Fit Layout
   final double bottomActionsBarSize;

   /// when widget that hold sharara video player
   /// dispose , the player controller will automatically pause the video
   ///
   /// set to false if you do not want that
   final bool autoPauseAfterDispose;


   /// set the Size of Big Icons
   final double bigIconsSize;

   /// do not change this critical for change the size of video player
   final bool convexMirror;
   /// if you want to hide the top volume controller
   final bool showTopVolumeController;
   /// build context popper icon button to get back
   final bool withPopIcon;
   /// set bottom Bar Actions Widgets
   /// also you can set stack children widgets
   final Widget Function(BuildContext,VideoPlayerValue)? actionBuilder;
   /// for building children widgets as stack with video player
   final List<Widget> Function(BuildContext,VideoPlayerValue)? stackChildren;
 }