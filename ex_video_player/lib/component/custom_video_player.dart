import 'package:ex_video_player/component/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class CustomVideoPlayer extends StatefulWidget {

  final XFile video;
  final GestureTapCallback onNewVideoPressed;

  CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();

}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {

  VideoPlayerController? videoController;
  bool showControls = false;

  @override
  void initState() {
    super.initState();

    initializeController(); //컨트롤러 초기화
  }

  initializeController() async {
    final videoController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoController.initialize();

    //컨트롤러 속성이 변경될 때마다 실행할 함수 등록
    videoController.addListener(videoControllerListener);

    setState(() {
      this.videoController = videoController;
    });
  }

  void videoControllerListener() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    if (videoController == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: (){
        setState(() {
          showControls = !showControls;
        });
      },
      child: AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(
                  videoController!
              ),
              if(showControls)
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      renderTimeTextFromDuration(
                        //동영상 현재 위치
                        videoController!.value.position,
                      ),
                      Expanded(
                        child: Slider(
                          onChanged: (double val) {
                            videoController!.seekTo(
                              Duration(seconds: val.toInt()),
                            );
                          },
                          value: videoController!.value.position.inSeconds.toDouble(),
                          min: 0,
                          max: videoController!.value.duration.inSeconds.toDouble(),
                        ),
                      ),
                      renderTimeTextFromDuration(
                        //동영상 총 길이
                        videoController!.value.duration,
                      ),
                    ],
                  ),
                ),
              ),
              if(showControls)
              Align(
                alignment: Alignment.topRight,
                child: CustomIconButton(
                  onPressed: widget.onNewVideoPressed,
                  iconData: Icons.photo_camera_back,
                ),
              ),
              if(showControls)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomIconButton(
                      onPressed: onReversePressed, iconData: Icons.rotate_left,
                    ),
                    CustomIconButton(
                      onPressed: onPlayPressed, iconData: videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    CustomIconButton(
                      onPressed: onForwardPressed, iconData: Icons.rotate_right,
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );


  }

  // covariant 키워드는 CustomVideoPlayer 클래스의 상속된 값도 허가해준다.
  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.video.path != widget.video.path) {
      initializeController();
    }
  }

  @override
  void dispose() {
    videoController!.removeListener(videoControllerListener);
    super.dispose();
  }

  //되감기 버튼
  void onReversePressed() {
    final currentPosition =  videoController!.value.position;
    Duration position = Duration();
    if(currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  //앞으로 감기 버튼
  void onForwardPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds > currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onPlayPressed() {
    if (videoController!.value.isPlaying) {
      videoController?.pause();
    }else {
      videoController?.play();
    }
  }

  Widget renderTimeTextFromDuration(Duration duration) {
    return Text(
      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
      style: TextStyle(
        color: Colors.white
      ),
    );
  }

}
