import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharara_video_player/src/controller.dart';
import 'package:sharara_video_player/video_player_sharara.dart';
import 'package:video_player/video_player.dart';

 class ShararaVideoPlayer extends StatefulWidget {
   const ShararaVideoPlayer({super.key,
     required this.controller,
     this.options = const Options()
   });
   /// specifying options of video controller
   final Options options;
   /// define the controller which manage video playing
   final ShararaVideoPlayerController controller;
   @override
   State<ShararaVideoPlayer> createState() => __ShararaVideoPlayerState();
 }
  final class _PlayerStateManagement {
     final ValueNotifier<Widget> notifier;
     _PlayerStateManagement(this.notifier);
  }
 class __ShararaVideoPlayerState extends State<ShararaVideoPlayer> {
   late final _PlayerStateManagement stateManagement;

   _reloadCallback(){
     if( !mounted)return;
     stateManagement.notifier.value = _ShararaVideoPlayer(
       key:UniqueKey(),
       controller:widget.controller,
       options:widget.options,
     );
   }
   @override
  void initState() {
     widget.controller.setRefreshUiCallback(_reloadCallback);
    stateManagement = _PlayerStateManagement(ValueNotifier(
      _ShararaVideoPlayer(
        controller:widget.controller,
        options:widget.options,
      )
    ));
    super.initState();
  }

  @override
  void dispose() {
     super.dispose();
     Future.delayed(const Duration(seconds:4)).then((_)=>stateManagement.notifier.dispose());
   }
   @override
   Widget build(BuildContext context) {
     return ValueListenableBuilder(valueListenable: stateManagement.notifier,
         builder:(c,v,_)=>v);
   }
 }


class _ShararaVideoPlayer extends StatefulWidget {
  const _ShararaVideoPlayer({super.key,
   required this.controller,
    this.options = const Options(),
  });
  /// specifying options of video controller
  final Options options;
  /// define the controller which manage video playing
  final ShararaVideoPlayerController controller;



  @override
  State<_ShararaVideoPlayer> createState() => _ShararaVideoPlayerState();
}

class _ShararaVideoPlayerState extends State<_ShararaVideoPlayer>
  {
  bool increasingLoopTrigger = false;

  bool decreasingLoopTrigger = false;

  ValueNotifier<double> get bottomPosition => controller.bottomPosition;
  ShararaVideoPlayerController get controller => widget.controller;
  Color get bottomActionsBarColor => (widget.options.bottomActionsBarColor ??  Colors.white);
  Color get bottomActionsBarBackgroundColor => (widget.options.bottomActionsBarBackgroundColor ??  Colors.black
      .withValues(alpha:0.5));
  bool isFullScreen = false;

  @override
  void initState() {
    if(!widget.options.convexMirror && widget.options.autoInitialize){
      controller.initialize();
    }
    if(widget.options.autoLoop){
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
    if(!widget.options.convexMirror && widget.options.autoPauseAfterDispose){
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds:100))
              .then((value) => controller.pause());
        });
    }
    super.dispose();
  }

  double get bottomHeight => widget.options.bottomActionsBarHeight??70;
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
      height:widget.options.height,
      width:widget.options.width,
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
                                        width:widget.options.width??width,
                                        color:bottomActionsBarBackgroundColor.withValues(alpha:0.3),
                                        child:widget.options.actionBuilder!=null?
                                        widget.options.actionBuilder!(context,value)
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
                                                        ) {
                                                                return const SizedBox();
                                                              }
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
                                                                thumbColor:Colors.white.withValues(alpha:0.0),
                                                                max:100,
                                                                min:0,
                                                                inactiveColor:bottomActionsBarColor
                                                                .withValues(alpha:0.2),
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
                                                          size:widget.options.bottomActionsBarSize,
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:MainAxisAlignment.end,
                                                          crossAxisAlignment:CrossAxisAlignment.center,
                                                          children: [

                                                            if(
                                                              ( widget.options.showViewModes &&
                                                               !widget.options.showViewModesOnlyWithFullScreen)
                                                            || widget.options.showViewModes && widget.options.convexMirror
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
                                                            Expanded(
                                                              child: LayoutBuilder(
                                                                builder: (context,constraints) {
                                                                 if ( constraints.containsNan )return const SizedBox();
                                                                 final double width = (constraints
                                                                 .maxWidth / 1 ) >= 80 ?
                                                                 80:
                                                                 constraints.maxWidth;
                                                                 return Row(
                                                                   mainAxisAlignment:MainAxisAlignment.end,
                                                                   children: [
                                                                     Flexible(
                                                                       child: SizedBox(
                                                                         width:width,
                                                                         child: SliderTheme(
                                                                           data:SliderThemeData(
                                                                               trackHeight:1,
                                                                               thumbShape: const RoundSliderThumbShape(
                                                                                 enabledThumbRadius: 6.0, // Adjust the size as needed
                                                                               ),
                                                                               overlayShape: SliderComponentShape.noOverlay),
                                                                           child:Slider(
                                                                             min: 0,
                                                                             max: 1,
                                                                             onChanged:(v){
                                                                               _extendLastDateTimeForDisableHiding();
                                                                               controller.setVolume(v);
                                                                             },
                                                                             activeColor:bottomActionsBarColor,
                                                                             thumbColor:bottomActionsBarColor.withValues(alpha:0.4),
                                                                             inactiveColor:bottomActionsBarColor
                                                                                 .withValues(alpha:0.5),
                                                                             value:value.volume,
                                                                           ),
                                                                         ),
                                                                       ),
                                                                     ),
                                                                   ],
                                                                 );
                                                                }
                                                              ),
                                                            ),
                                                           SizedBox(
                                                             width:(widget.options.bottomActionsBarSize * 2) + 15,
                                                             child:Row(
                                                               children: [
                                                                 const SizedBox(width:6,),
                                                                 if(value.volume==0)
                                                                   InkWell(
                                                                     onTap:()=>_onClick(controller.deMute),
                                                                     child: Icon(Icons.volume_off,
                                                                       color:bottomActionsBarColor,
                                                                       size:widget.options.bottomActionsBarSize,
                                                                     ),
                                                                   )
                                                                 else
                                                                   InkWell(
                                                                     onTap:()=>_onClick(controller.mute),
                                                                     child: Icon(Icons.volume_up_outlined,
                                                                       color:bottomActionsBarColor,
                                                                       size:widget.options.bottomActionsBarSize,
                                                                     ),
                                                                   ),

                                                                 const SizedBox(width:8,),
                                                                 InkWell(
                                                                   onTap:()async{

                                                                     if(widget.options.convexMirror){
                                                                       Navigator.maybePop(context);
                                                                       return;
                                                                     }
                                                                     if(!mounted)return;
                                                                     setState(() {
                                                                       isFullScreen = true;
                                                                     });

                                                                     final Widget child =   FullScreenMode(

                                                                       controller:controller,
                                                                       applyOrientationsEnforcement:widget.options.applyOrientationsEnforcement,
                                                                       onDispose:(){
                                                                         Future.delayed(const Duration(
                                                                             milliseconds:100
                                                                         )).then((value) {
                                                                           WidgetsBinding
                                                                               .instance
                                                                               .addPostFrameCallback((timeStamp) {
                                                                             if(!mounted)return;
                                                                             setState(() {
                                                                               isFullScreen = false;
                                                                             });
                                                                           });
                                                                         });
                                                                       },
                                                                     );
                                                                     if(widget.options.onNavigate!=null){
                                                                       return widget.options.onNavigate!(child);
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
                                                                     widget.options.convexMirror?
                                                                     Icons.fullscreen_exit:
                                                                     Icons.fullscreen,
                                                                     color:bottomActionsBarColor,
                                                                     size:widget.options.bottomActionsBarSize,
                                                                   ),
                                                                 ),
                                                               ],
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
                                child: widget.options.addReloadOptionWhenFailed != null ?

                                PopupMenuButton(
                                  onSelected:(final String message){
                                    switch(message) {
                                      case "reload":
                                        controller.rebuildInternalPlayerController();
                                        widget.options.addReloadOptionWhenFailed!(controller.playerController);
                                        break;
                                    }
                                  },
                                  itemBuilder:(_)=>[
                                    PopupMenuItem(
                                      value:"reload",
                                      child:Text(widget.options.reloadTitle),
                                    )
                                  ],
                                  child: Icon(Icons.error,
                                    size:widget.options.bigIconsSize,
                                    color:bottomActionsBarColor,),
                                ):Icon(Icons.error,
                                  size:widget.options.bigIconsSize,
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
                                          color:Colors.black.withValues(alpha:0.2),
                                          height:height,
                                          width:width,
                                        ),
                                      ),

                                      Column(
                                        mainAxisSize:MainAxisSize.max,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height:40,),
                                          if(widget.options.convexMirror || (widget.options.withPopIcon))
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              crossAxisAlignment:CrossAxisAlignment.start,

                                              children: [
                                                const SizedBox(width:2,),
                                                InkWell(
                                                  onTap:(){
                                                    Navigator.maybePop(context);
                                                  },
                                                  borderRadius:BorderRadius.circular(15),
                                                  child:const Padding(
                                                    padding:  EdgeInsets.all(8.0),
                                                    child:  Icon(
                                                      Icons.arrow_back_ios_new,size:28,
                                                      color:Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          if(widget.options.showTopVolumeController &&
                                           mainLayoutConstraints.maxHeight >= 280 &&
                                           mainLayoutConstraints.maxWidth >= 250
                                          )
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
                                                  color:bottomActionsBarColor.withValues(alpha:0.2),
                                                  size:widget.options.bigIconsSize,
                                                ),
                                              ),
                                              Container(
                                                padding:const EdgeInsets.all(20.0),
                                                decoration:BoxDecoration(
                                                    shape:BoxShape.circle,
                                                    color: bottomActionsBarBackgroundColor
                                                    .withValues(alpha:0.2)
                                                ),
                                                child:Column(
                                                  children: [
                                                    Icon(Icons.volume_up_outlined,
                                                      color:bottomActionsBarColor
                                                          .withValues(alpha:0.4),
                                                      size:widget.options.bigIconsSize-5,
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
                                                child: Icon(Icons.add_circle,
                                                  color:bottomActionsBarColor
                                                      .withValues(alpha:0.2),
                                                  size:widget.options.bigIconsSize-5,
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
                                                color:bottomActionsBarColor.withValues(alpha:0.6),                                         ),
                                            )
                                            ),
                                            Expanded(
                                                child:
                                            (value.isBuffering)
                                                ?
                                            Center(child:SizedBox(
                                              height:10,
                                              width:20,
                                              child:LinearProgressIndicator(
                                                backgroundColor:bottomActionsBarBackgroundColor,
                                                color:bottomActionsBarColor.withValues(alpha:0.4),
                                              ),
                                            ),)
                                                :
                                            GestureDetector(
                                              onTap:()=>_onClick(controller.toggle),
                                              child: Icon(
                                                playIcons,color:bottomActionsBarColor.withValues(alpha:0.6),
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
                                                color:bottomActionsBarColor.withValues(alpha:0.6),                                         ),
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
                                    height:widget.options.height?? height,
                                    bottomActionsBarColor:bottomActionsBarColor,
                                    onCall:(){
                                      controller.plusScrubbing(4);
                                    }
                                ),
                                RightAceClicker(
                                    height:widget.options.height??height,
                                    bottomActionsBarColor:bottomActionsBarColor,
                                    onCall:(){
                                      controller.minusScrubbing(4);
                                    }
                                ),
                              ],
                            ),
                            if(widget.options.stackChildren!=null)
                              ...widget.options.stackChildren!(context,value)
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
    if(!mounted)return;
    setState(() {
      triggered = true;
    });
    await Future.delayed(const Duration(milliseconds:300));
    if(!mounted)return;
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
   if(!mounted)return;
   setState(() {
   triggered = true;
   });
  await Future.delayed(const Duration(milliseconds:300));
   if(!mounted)return;
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
      controller: widget.controller,
      options:const Options(convexMirror: true)
    );
  }
}





