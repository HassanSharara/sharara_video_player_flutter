import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharara_video_player/video_player_sharara.dart';
import 'package:video_player/video_player.dart';

class ShararaVideoPlayer extends StatefulWidget {
  const ShararaVideoPlayer({super.key,
   required this.controller,
    this.bottomActionsBarHeight,
    this.bottomActionsBarColor,
    this.bottomActionsBarBackgroundColor,
    this.actionBuilder,
    this.height,
    this.onNavigate,
    this.width,
    this.autoInitialize = true,
    this.applyOrientationsEnforcement = true,
    this.convexMirror = false,
    this.autoLoop = false,
    this.showTopVolumeController = true,
    this.autoPauseAfterDispose = true,
    this.showViewModes = false,
    this.showViewModesOnlyWithFullScreen = true,
    this.bottomActionsBarSize = 28,
    this.bigIconsSize = 40,
  });


  /// auto buffering the video
  final bool autoInitialize ;

  /// this option will force the view port and the Preferred Orientations to be the same as the video Orientations
  final bool applyOrientationsEnforcement ;

  /// auto looping the video
  final bool autoLoop ;
  /// options about how to view video
  final bool showViewModes ;

  /// show view mode only when screen is full
  final bool showViewModesOnlyWithFullScreen ;
  /// define the controller which manage video playing
  final ShararaVideoPlayerController controller;

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
  /// set bottom Bar Actions Widgets
  final Widget Function(BuildContext,VideoPlayerValue)? actionBuilder;
  @override
  State<ShararaVideoPlayer> createState() => _ShararaVideoPlayerState();
}

class _ShararaVideoPlayerState extends State<ShararaVideoPlayer>
  {
  bool increasingLoopTrigger = false;

  bool decreasingLoopTrigger = false;

  ValueNotifier<double> get bottomPosition => controller.bottomPosition;
  ShararaVideoPlayerController get controller => widget.controller;
  Color get bottomActionsBarColor => (widget.bottomActionsBarColor ??  Colors.white);
  Color get bottomActionsBarBackgroundColor => (widget.bottomActionsBarBackgroundColor ??  Colors.black.withOpacity(0.5));
  bool isFullScreen = false;

  @override
  void initState() {
    if(!widget.convexMirror && widget.autoInitialize){
      controller.initialize();
    }
    if(widget.autoLoop){
      controller.setLooping(true);
    }
    super.initState();
    WidgetsBinding
    .instance
    .addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2))
          .then((value) => _onClick());
    });
  }


  @override
  void dispose() {
    if(!widget.convexMirror && widget.autoPauseAfterDispose){
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds:100))
              .then((value) => controller.pause());
        });
    }
    super.dispose();
  }

  double get bottomHeight => widget.bottomActionsBarHeight??70;
  DateTime? lastDateTime;

  _onClick([final Function()? callBack]){
    if(controller.isDisposed)return;
    final int dif = this.dif;
    if ( lastDateTime!=null && callBack==null){
      if(
      dif < 5 && dif>=0  ){
        _closeControls();
        lastDateTime = DateTime.now().subtract(const Duration(seconds:6));
        return;
      }
    }
    lastDateTime = DateTime.now();
    if(bottomPosition.value!=0){
      bottomPosition.value = 0;
    }
    _autoHideMicroWorker();
    if(callBack!=null){
      callBack();
    }
  }

  int get dif => DateTime.now()
      .difference(lastDateTime??DateTime.now()).inSeconds;
  bool get needToHide =>  dif >= 4;
  _autoHideMicroWorker()async{
    await Future.delayed(const Duration(seconds:4));
    if(
    needToHide
         ){
      _closeControls();
    }
  }
  _closeControls(){
    if(controller.isDisposed)return;
    bottomPosition.value = - (bottomHeight+30);
  }

  @override
  Widget build(BuildContext context) {

    return  SizedBox(
      height:widget.height,
      width:widget.width,
      child: GestureDetector(
        onTap:_onClick,
        child: Scaffold(
          backgroundColor:Colors.black,
          body: Directionality(
            textDirection:TextDirection.ltr,
            child: LayoutBuilder(
              builder:(final BuildContext context,final BoxConstraints mainLayoutConstraints){
                if(mainLayoutConstraints.containsNan)return const SizedBox();
                final double width = mainLayoutConstraints.maxWidth;
                final double height = mainLayoutConstraints.maxHeight;
                return SizedBox(

                  height: mainLayoutConstraints.maxHeight,
                  width: mainLayoutConstraints.maxWidth,
                  child: ValueListenableBuilder(
                      key:UniqueKey(),
                      valueListenable: controller.playerController,
                      builder:(BuildContext context,final VideoPlayerValue value,_){

                        return Stack(
                          children: [
                            if(isFullScreen)
                              const SizedBox()
                            else
                              ValueListenableBuilder(valueListenable:controller.viewMode,
                                  child:VideoPlayer(
                                      widget.controller.playerController
                                  ),
                                  builder:(BuildContext context,viewMode,final Widget? playerWidget){
                                if(viewMode==null){
                                  return Center(
                                    child: AspectRatio(
                                      aspectRatio:widget.controller.playerController.value
                                          .aspectRatio,
                                      child:playerWidget!,
                                    ),
                                  );
                                }

                                if(viewMode.aspectRatio==null){
                                  return playerWidget!;
                                }

                                 return AspectRatio(
                                   aspectRatio:viewMode.aspectRatio!,
                                   child:playerWidget,
                                  );
                             }),

                            ValueListenableBuilder(
                                valueListenable:bottomPosition,
                                builder:(BuildContext context,final double bp,_){
                                  return  AnimatedPositioned(
                                      duration:const Duration(milliseconds:300),
                                      bottom:bp,
                                      child: Container(
                                        height:bottomHeight,
                                        width:widget.width??width,
                                        color:bottomActionsBarBackgroundColor.withOpacity(0.3),
                                        child:widget.actionBuilder!=null?
                                        widget.actionBuilder!(context,value)
                                            :Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            mainAxisAlignment:MainAxisAlignment.center,
                                            crossAxisAlignment:CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: LayoutBuilder(
                                                      builder:(c,BoxConstraints layout){

                                                        if(
                                                       // !value.isInitialized ||
                                                        layout.containsNan
                                                        )return const SizedBox();
                                                        double currentWidgetWidth = layout.maxWidth;
                                                        if (currentWidgetWidth.isNaN)return const SizedBox();
                                                        return SizedBox(
                                                          height:8,
                                                          width:currentWidgetWidth,
                                                          child: SliderTheme(
                                                            data:SliderThemeData(
                                                                trackHeight:5,
                                                                overlayShape:SliderComponentShape.noThumb),
                                                            child: Slider(
                                                                value:value.progressPercentage,
                                                                onChanged:(final double factor){
                                                                  _updateProgressTo(factor,value);
                                                                },
                                                                thumbColor:Colors.white.withOpacity(0.0),
                                                                max:100,
                                                                min:0,
                                                                inactiveColor:bottomActionsBarColor
                                                                .withOpacity(0.2),
                                                                activeColor:bottomActionsBarColor,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width:5,),
                                                  Text(
                                                    "${value.position
                                                        .toValidString} / ${value.duration
                                                        .toValidString}",
                                                    style: TextStyle(
                                                        fontSize:10,
                                                        color:bottomActionsBarColor
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                    children:
                                                    [
                                                      GestureDetector(
                                                        onTap:()=>_onClick(controller.toggle),
                                                        child:

                                                        Icon(
                                                          playIcons,
                                                          color:bottomActionsBarColor,
                                                          size:widget.bottomActionsBarSize,
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:MainAxisAlignment.end,
                                                          crossAxisAlignment:CrossAxisAlignment.center,
                                                          children: [

                                                            if(
                                                              ( widget.showViewModes &&
                                                               !widget.showViewModesOnlyWithFullScreen)
                                                            || widget.showViewModes && widget.convexMirror
                                                             )
                                                            PopupMenuButton<ViewModeDimensions?>(
                                                              onSelected:(ViewModeDimensions? dimension){
                                                                controller.setDimension(dimension);
                                                              },
                                                              itemBuilder: (BuildContext context) =>[
                                                                 PopupMenuItem(
                                                                  onTap:()=>controller.setDimension(null),
                                                                  value:null,child:const Text("Normal"),),
                                                                ... controller.dimensions
                                                                .map((e) =>
                                                                 PopupMenuItem(
                                                                     value:e,
                                                                     child:e.icon ?? Text(e.hint??""),
                                                                 )
                                                                )
                                                              ],
                                                              child: ValueListenableBuilder(
                                                                valueListenable:controller.viewMode,
                                                                builder:(BuildContext context,viewMode,_){
                                                                  return Container(
                                                                    margin:const EdgeInsets.symmetric(
                                                                      horizontal:8.0
                                                                    ),
                                                                    constraints:const BoxConstraints(
                                                                      maxWidth:50,
                                                                      maxHeight:50
                                                                    ),
                                                                    child:
                                                                    FittedBox(
                                                                      fit:BoxFit.fill,
                                                                      child:viewMode==null?
                                                                      Text("NORMAL",style:TextStyle(
                                                                          color:bottomActionsBarColor
                                                                      ),):
                                                                      viewMode.icon??
                                                                          Text(viewMode.hint??"",
                                                                            style:TextStyle(
                                                                                color:bottomActionsBarColor
                                                                            ),
                                                                          )
                                                                    )
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(width:5,),
                                                            ConstrainedBox(
                                                              constraints:const BoxConstraints(
                                                                  maxWidth:80
                                                              ),
                                                              child:SliderTheme(
                                                                data:SliderThemeData(
                                                                    trackHeight:1,
                                                                    overlayShape: SliderComponentShape.noOverlay),

                                                                child:Slider(
                                                                  min: 0,
                                                                  max: 1,
                                                                  onChanged:(v){
                                                                    _extendLastDateTimeForDisableHiding();
                                                                    controller.setVolume(v);
                                                                  },
                                                                  activeColor:bottomActionsBarColor,
                                                                  thumbColor:bottomActionsBarColor.withOpacity(0.4),
                                                                  value:value.volume,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width:6,),
                                                            if(value.volume==0)
                                                              InkWell(
                                                                onTap:()=>_onClick(controller.deMute),
                                                                child: Icon(Icons.volume_off,
                                                                  color:bottomActionsBarColor,
                                                                  size:widget.bottomActionsBarSize,
                                                                ),
                                                              )
                                                            else
                                                              InkWell(
                                                                onTap:()=>_onClick(controller.mute),
                                                                child: Icon(Icons.volume_up_outlined,
                                                                  color:bottomActionsBarColor,
                                                                  size:widget.bottomActionsBarSize,
                                                                ),
                                                              ),

                                                            const SizedBox(width:8,),
                                                            InkWell(
                                                              onTap:()async{

                                                                if(widget.convexMirror){
                                                                  Navigator.maybePop(context);
                                                                  return;
                                                                }
                                                                setState(() {
                                                                  isFullScreen = true;
                                                                });

                                                                final Widget child =   FullScreenMode(

                                                                  controller:controller,
                                                                  applyOrientationsEnforcement:widget.applyOrientationsEnforcement,
                                                                  onDispose:(){
                                                                    Future.delayed(const Duration(
                                                                        milliseconds:100
                                                                    )).then((value) {
                                                                      WidgetsBinding
                                                                          .instance
                                                                          .addPostFrameCallback((timeStamp) {
                                                                        setState(() {
                                                                          isFullScreen = false;
                                                                        });
                                                                      });
                                                                    });
                                                                  },
                                                                );
                                                                if(widget.onNavigate!=null){
                                                                  return widget.onNavigate!(child);
                                                                }

                                                                Navigator
                                                                    .push(context,
                                                                    MaterialPageRoute(
                                                                        builder:(_)=>
                                                                        child
                                                                    )
                                                                );
                                                              },
                                                              child: Icon(
                                                                widget.convexMirror?
                                                                Icons.fullscreen_exit:
                                                                Icons.fullscreen,
                                                                color:bottomActionsBarColor,
                                                                size:widget.bottomActionsBarSize,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  );
                                }),

                            if(value.errorDescription!=null)
                              Center(
                                child: Icon(Icons.error,
                                  size:widget.bigIconsSize,
                                  color:bottomActionsBarColor,),
                              )

                            else
                            ValueListenableBuilder(
                                valueListenable: bottomPosition,
                                builder:(BuildContext context,final double bd,_)
                                {
                                  if(bd<0)return const SizedBox();
                                  return  Stack(
                                    children: [
                                      IgnorePointer(
                                        ignoring:true,
                                        child: Container(
                                          color:Colors.black.withOpacity(0.2),
                                          height:height,
                                          width:width,
                                        ),
                                      ),

                                      Column(
                                        mainAxisSize:MainAxisSize.max,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          SizedBox(height:height*0.1,),
                                          if(widget.showTopVolumeController)
                                          Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceAround,
                                            children: [
                                              GestureDetector(
                                                onLongPressStart:(_)async{
                                                  decreasingLoopTrigger = true;
                                                  increasingLoopTrigger = false;
                                                  while(decreasingLoopTrigger){
                                                    _extendLastDateTimeForDisableHiding();
                                                    await Future.delayed(const Duration(
                                                        milliseconds:50
                                                    ));
                                                    controller.decreaseVolumeBy(0.01);
                                                    if(controller.playerController.value
                                                        .volume<=0.01){
                                                      increasingLoopTrigger = false;
                                                      decreasingLoopTrigger = false;
                                                      break;
                                                    }
                                                  }
                                                },
                                                onLongPressEnd:(_){
                                                  increasingLoopTrigger = false;
                                                  decreasingLoopTrigger = false;
                                                },
                                                onTap:(){
                                                  increasingLoopTrigger = false;
                                                  decreasingLoopTrigger = false;
                                                  _onClick(
                                                          ()=>
                                                          controller.
                                                          decreaseVolumeBy(0.01)
                                                  );
                                                },
                                                child: Icon(Icons.remove_circle,
                                                  color:bottomActionsBarColor.withOpacity(0.6),
                                                  size:widget.bigIconsSize,
                                                ),
                                              ),
                                              Container(
                                                padding:const EdgeInsets.all(20.0),
                                                decoration:BoxDecoration(
                                                    shape:BoxShape.circle,
                                                    color: bottomActionsBarBackgroundColor
                                                    .withOpacity(0.2)
                                                ),
                                                child:Column(
                                                  children: [
                                                    Icon(Icons.volume_up_outlined,
                                                      color:bottomActionsBarColor
                                                          .withOpacity(0.4),
                                                      size:widget.bigIconsSize-5,
                                                    ),
                                                    const SizedBox(height:5,),
                                                    Text((value.volume*100).toStringAsFixed(0),
                                                      style:TextStyle(color:bottomActionsBarColor),
                                                    )
                                                  ],
                                                ),

                                              ),
                                              GestureDetector(
                                               onLongPressStart:(_)async{
                                                 increasingLoopTrigger = true;
                                                 decreasingLoopTrigger = false;
                                                 while(increasingLoopTrigger){
                                                   _extendLastDateTimeForDisableHiding();
                                                   await Future.delayed(const Duration(
                                                     milliseconds:50
                                                   ));
                                                   controller.increaseVolumeBy(0.01);
                                                   if(controller.playerController.value
                                                   .volume>=0.99){
                                                     increasingLoopTrigger = false;
                                                     decreasingLoopTrigger = false;
                                                     break;
                                                   }
                                                 }
                                               },
                                                onLongPressEnd:(_){
                                                  increasingLoopTrigger = false;
                                                  decreasingLoopTrigger = false;
                                                },
                                                onTap:(){
                                                  increasingLoopTrigger = false;
                                                  decreasingLoopTrigger = false;
                                                  _onClick(
                                                      ()=>
                                                      controller
                                                      .increaseVolumeBy(0.01)
                                                  );
                                                },
                                                onLongPress:(){},
                                                child: Icon(Icons.add_circle,
                                                  color:bottomActionsBarColor
                                                      .withOpacity(0.4),
                                                  size:widget.bigIconsSize-5,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Center(
                                        child:Row(
                                          children: [
                                            Expanded(child:
                                            GestureDetector(
                                              onTap:()=>
                                                  _onClick(()=>controller.minusScrubbing(10)),
                                              child: Icon(
                                                Icons.keyboard_double_arrow_left_rounded,
                                                size:35,
                                                color:bottomActionsBarColor.withOpacity(0.6),                                         ),
                                            )
                                            ),
                                            Expanded(child:
                                            (value.isBuffering)
                                                ?
                                            Center(child:SizedBox(
                                              height:10,
                                              width:20,
                                              child:LinearProgressIndicator(
                                                backgroundColor:bottomActionsBarBackgroundColor,
                                                color:bottomActionsBarColor,
                                              ),
                                            ),)
                                                :
                                            GestureDetector(
                                              onTap:()=>_onClick(controller.toggle),
                                              child: Icon(
                                                playIcons,color:bottomActionsBarColor.withOpacity(0.6),
                                                size:50,
                                              ),
                                            )),
                                            Expanded(child:
                                            GestureDetector(
                                              onTap:()=>_onClick(
                                                      ()=>controller.plusScrubbing(10)
                                              ),
                                              child: Icon(
                                                Icons.keyboard_double_arrow_right_rounded,
                                                size:35,
                                                color:bottomActionsBarColor.withOpacity(0.6),                                         ),
                                            )
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );

                                }
                                ),
                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              textDirection:TextDirection.ltr,
                              children: [
                                LeftAceClicker(
                                    height:widget.height?? height,
                                    bottomActionsBarColor:bottomActionsBarColor,
                                    onCall:(){
                                      controller.plusScrubbing(4);
                                    }
                                ),
                                RightAceClicker(
                                    height:widget.height??height,
                                    bottomActionsBarColor:bottomActionsBarColor,
                                    onCall:(){
                                      controller.minusScrubbing(4);
                                    }
                                ),
                              ],
                            )

                          ],
                        );
                      }
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  IconData get playIcons {
    final player =  controller.playerController.value;
    if(player.isCompleted)return Icons.refresh;
    if(player.isPlaying)return Icons.pause_circle;
    return Icons.play_circle;
  }

  _extendLastDateTimeForDisableHiding(){
    if(
    lastDateTime ==null ||
        DateTime.now()
            .difference(
            lastDateTime!
        ).inSeconds >= 3
    ){
      lastDateTime = DateTime.now();
      _autoHideMicroWorker();
    }
  }
  void _updateProgressTo(final double factor,final VideoPlayerValue value) {
    _extendLastDateTimeForDisableHiding();
    final Duration seekTo = Duration(seconds:value.duration.inSeconds * factor~/100);
    controller
        .seekTo(seekTo);
  }

  }

  extension CN on BoxConstraints {
  bool get containsNan => maxWidth.isNaN ||
     maxHeight.isNaN ||
     minHeight.isNaN ||
     minWidth.isNaN;
  }
extension ToString on Duration {
  String get toValidString {
    int milliSeconds = inMilliseconds;
    int seconds = 0;
    int minutes = 0;
    int hours = 0 ;
    while(milliSeconds>=1000){
      milliSeconds-=1000;
      seconds++;
    }
    while(seconds>=60){
      seconds-=60;
      minutes++;
    }
    while(minutes>=60){
      minutes-=60;
      hours++;
    }
    return "$hours:$minutes:$seconds";
  }
}


extension PercentageCalculator on VideoPlayerValue {
  double get progressPercentage {
  final double res = position.inSeconds * 100 /
        duration.inSeconds;

  if ( res >= 100 )return 100;
  if ( res <= 0 || res.isNaN)return 0;
  return res;
  }
}


class LeftAceClicker extends StatefulWidget {
  const LeftAceClicker({super.key,
    required this.height,
    this.onCall,
    this.bottomActionsBarColor,
  });
  final Function()? onCall;
  final double height;
  final Color? bottomActionsBarColor;

  @override
  State<LeftAceClicker> createState() => _LeftAceClickerState();
}

class _LeftAceClickerState extends State<LeftAceClicker> {
  bool triggered = false;
  DateTime? lastTriggeredTime;

  void _trigger()async{
    if(widget.onCall==null)return;
    widget.onCall!();
    setState(() {
      triggered = true;
    });
    await Future.delayed(const Duration(milliseconds:300));
    setState(() {
      triggered = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap:_trigger,
      child:  AnimatedOpacity(
        duration:const Duration(milliseconds:200),
        opacity:triggered?1.0:0.0,
        child: Column(
          children: [
            Container(
              constraints:const BoxConstraints(
                  maxWidth:70
              ),
              height:widget.height,
              child: Center(
                child:Icon(Icons.keyboard_double_arrow_left_sharp,
                  color:widget.bottomActionsBarColor??Colors.white,
                  size:40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightAceClicker extends StatefulWidget {
  const RightAceClicker({super.key,
    required this.height,
    this.onCall,
    this.bottomActionsBarColor,
  });
  final Function()? onCall;
  final double height;
  final Color? bottomActionsBarColor;

  @override
  State<RightAceClicker> createState() => _RightAceClickerState();
}

class _RightAceClickerState extends State<RightAceClicker> {
  bool triggered = false;
  DateTime? lastTriggeredTime;

  void _trigger()async{
   if(widget.onCall==null)return;
   widget.onCall!();
   setState(() {
   triggered = true;
   });
  await Future.delayed(const Duration(milliseconds:300));
   setState(() {
    triggered = false;
   });
}
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap:_trigger,
      child: AnimatedOpacity(
        duration:const Duration(milliseconds:200),
        opacity:triggered?1.0:0.0,
        child:Column(
          children: [
            Container(
              constraints:const BoxConstraints(
                  maxWidth:70
              ),
              height:widget.height,
              child: Center(
                child:Icon(Icons.keyboard_double_arrow_right_sharp,
                  color:widget.bottomActionsBarColor??Colors.white,
                  size:40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class FullScreenMode extends StatefulWidget {
  const FullScreenMode({super.key,
  required this.controller,
  this.fullScreenVideoPlayerMirror,
  this.onDispose,
  this.applyOrientationsEnforcement = true,
  });
  final Function()? onDispose;
  final ShararaVideoPlayerController controller;
  final VideoPlayer? fullScreenVideoPlayerMirror;
  final bool applyOrientationsEnforcement;
  @override
  State<FullScreenMode> createState() => _FullScreenModeState();
}

class _FullScreenModeState extends State<FullScreenMode> {
  ShararaVideoPlayerController get controller => widget.controller;
  late final bool isPortraitVideo;
  @override
  void initState() {
    isPortraitVideo = controller.playerController.value.size.height >
     controller.playerController.value.size.width;
    controller.isFullScreen = true;
    SystemChrome.setPreferredOrientations([
      if(!widget.applyOrientationsEnforcement)...[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]
      else
      if ( isPortraitVideo )...[
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]
      else ... [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],


    ]);
    super.initState();
  }
  @override
  void dispose() {
    controller.isFullScreen = false;
    super.dispose();
    if(widget.onDispose!=null){
      widget.onDispose!();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

  }
  @override
  Widget build(BuildContext context) {
    return ShararaVideoPlayer(
      convexMirror:true,
      controller: widget.controller,
    );
  }
}





