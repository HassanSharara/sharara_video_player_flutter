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
    this.convexMirror = false,
    this.autoLoop = false,
    this.bottomActionsBarSize = 25,
  });

  /// auto buffering the video
  final bool autoInitialize ;
  /// auto looping the video
  final bool autoLoop ;
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

  /// do not change this critical for change the size of video player
  final bool convexMirror;
  /// set bottom Bar Actions Widgets
  final Widget Function(BuildContext,VideoPlayerValue)? actionBuilder;
  @override
  State<ShararaVideoPlayer> createState() => _ShararaVideoPlayerState();
}

class _ShararaVideoPlayerState extends State<ShararaVideoPlayer>
  {
     ValueNotifier<double> get bottomPosition => controller.bottomPosition;
    ShararaVideoPlayerController get controller => widget.controller;
  Color get bottomActionsBarColor =>(widget.bottomActionsBarColor ??  Colors.white);
  Color get bottomActionsBarBackgroundColor =>(widget.bottomActionsBarBackgroundColor ??  Colors.black.withOpacity(0.5));
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
    if(!widget.convexMirror){
      controller.pause();
    }
    super.dispose();
  }

  double get bottomHeight => widget.bottomActionsBarHeight??60;
  DateTime? lastDateTime;

  _onClick([final Function()? callBack]){
    if(controller.isDisposed)return;
    if ( lastDateTime!=null && callBack==null){
      final int dif = DateTime.now().difference(lastDateTime!).inSeconds;
      if(
      dif < 3 && dif>0  ){
        _closeControls();
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
  _autoHideMicroWorker()async{
    await Future.delayed(const Duration(seconds:4));
    final int difference =   DateTime.now()
        .difference(lastDateTime!).inSeconds;
    if(
        lastDateTime!=null &&
            difference== 4
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
      child: Scaffold(
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
                            InkWell(
                                onTap:_onClick,
                                child: VideoPlayer(widget.controller.playerController)),

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
                                        padding: const EdgeInsets.all(8.0),
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
                                                      layout.containsNan
                                                      )return const SizedBox();
                                                      double currentWidgetWidth = layout.maxWidth;
                                                      final double factor = (currentWidgetWidth/value.duration.inSeconds.toDouble()
                                                      ).toDouble();
                                                      double  microWidth =
                                                          factor
                                                              *value.position.inSeconds;
                                                      if(microWidth.isNaN){
                                                        microWidth = 0;
                                                      }
                                                      return GestureDetector(
                                                        onHorizontalDragUpdate:(DragUpdateDetails details){
                                                          _onClick((){});
                                                          double inSeconds = details.localPosition.distance /
                                                              factor ;
                                                          int seconds;

                                                          if(
                                                          inSeconds>=value.duration.inSeconds
                                                          ){
                                                            seconds = value.duration.inSeconds;
                                                          }
                                                          else if(inSeconds<0){
                                                            seconds = 0;
                                                          }
                                                          else{
                                                            seconds = inSeconds.toInt();
                                                          }


                                                          final Duration seekTo = Duration(seconds:seconds);
                                                          controller
                                                              .playerController
                                                              .seekTo(seekTo);
                                                        },
                                                        child: Stack(
                                                          children: [

                                                            Container(
                                                              height:8,
                                                              width:currentWidgetWidth,
                                                              decoration:BoxDecoration(
                                                                  borderRadius:BorderRadius.circular(15),
                                                                  color:Colors.grey.withOpacity(0.8)
                                                              ),
                                                            ),

                                                            Container(
                                                              height:8,
                                                              width:microWidth,
                                                              constraints:BoxConstraints(
                                                                  minWidth:0,
                                                                  maxWidth:microWidth,
                                                                  minHeight:0,
                                                                  maxHeight:8
                                                              ),
                                                              decoration:BoxDecoration(
                                                                  borderRadius:BorderRadius.circular(15),
                                                                  color:Colors.white
                                                              ),
                                                            ),

                                                          ],
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
                                                    InkWell(
                                                      onTap:()=>_onClick(controller.toggle),
                                                      child:Icon(
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
                                                          const SizedBox(width:5,),
                                                          GestureDetector(
                                                            onHorizontalDragUpdate:(details){
                                                              _onClick((){
                                                                double distance
                                                                = (details.localPosition.distance);
                                                                if(details.localPosition.direction>1){
                                                                  distance-=10;
                                                                }
                                                                if(details.localPosition.direction>=2){
                                                                  distance=0;
                                                                }
                                                                distance *=2;
                                                                double volume = (distance * 60 )/ 100;
                                                                volume/=100;
                                                                if(volume>1){
                                                                  volume = 1;
                                                                }else if (volume<0){
                                                                  volume = 0;
                                                                }
                                                                controller.setVolume(volume);
                                                              });
                                                            },
                                                            child: ConstrainedBox(
                                                              constraints:const BoxConstraints(
                                                                  maxWidth:60
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:MainAxisAlignment.end,
                                                                children: [
                                                                  LinearProgressIndicator(
                                                                    value:value.volume,
                                                                    color:bottomActionsBarColor,
                                                                    backgroundColor:bottomActionsBarBackgroundColor
                                                                        .withOpacity(0.6),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),

                                                          const SizedBox(width:5,),

                                                          if(value.volume==0)
                                                            GestureDetector(
                                                              onTap:()=>_onClick(()
                                                              =>controller.deMute()),
                                                              child: Icon(Icons.volume_off,
                                                                color:bottomActionsBarColor,
                                                                size:widget.bottomActionsBarSize,
                                                              ),
                                                            )
                                                          else
                                                            GestureDetector(
                                                              onTap:()=>_onClick(controller.mute),
                                                              child: Icon(Icons.volume_up_outlined,
                                                                color:bottomActionsBarColor,
                                                                size:widget.bottomActionsBarSize,
                                                              ),
                                                            ),

                                                          const SizedBox(width:5,),
                                                          GestureDetector(
                                                            onTap:()async{

                                                              if(widget.convexMirror){
                                                                Navigator.maybePop(context);
                                                                return;
                                                              }
                                                              setState(() {
                                                                isFullScreen = true;
                                                              });

                                                              final Widget child =   FullScreenMode(controller:controller,
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
                                size:40,
                                color:bottomActionsBarColor,),
                            )
                         else if(value.isBuffering)
                            Center(child:SizedBox(
                              height:10,
                              width:20,
                              child:LinearProgressIndicator(
                                backgroundColor:bottomActionsBarBackgroundColor,
                                color:bottomActionsBarColor,
                              ),
                            ),)
                          else
                          ValueListenableBuilder(
                              valueListenable: bottomPosition,
                              builder:(BuildContext context,final double bd,_){
                                if(bd<0)return const SizedBox();

                                return  GestureDetector(
                                  onTap:()=>_onClick(controller.toggle),
                                  child: Center(
                                    child:Icon(
                                      playIcons,color:Colors.white.withOpacity(0.6),
                                      size:50,
                                    ),
                                  ),
                                );

                              }),
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            textDirection:TextDirection.ltr,
                            children: [
                              LeftAceClicker(
                                  height:widget.height?? height,
                                  bottomActionsBarColor:bottomActionsBarColor,
                                  onCall:(){
                                    controller.seekTo(
                                        value.position - const Duration(seconds: 4)
                                    );
                                  }
                              ),
                              RightAceClicker(
                                  height:widget.height??height,
                                  bottomActionsBarColor:bottomActionsBarColor,
                                  onCall:(){
                                    controller.seekTo(
                                        value.position + const Duration(seconds: 4)
                                    );
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
    );
  }
  IconData get playIcons {
    final player =  controller.playerController.value;
    if(player.isCompleted)return Icons.refresh;
    if(player.isPlaying)return Icons.pause_circle;
    return Icons.play_circle;
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
    int seconds = inSeconds;
    int minutes = 0;
    int hours = 0 ;
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
  });
  final Function()? onDispose;
  final ShararaVideoPlayerController controller;
  final VideoPlayer? fullScreenVideoPlayerMirror;
  @override
  State<FullScreenMode> createState() => _FullScreenModeState();
}

class _FullScreenModeState extends State<FullScreenMode> {
  ShararaVideoPlayerController get controller => widget.controller;
  @override
  void initState() {
    controller.isFullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
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





