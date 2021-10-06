import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';

import 'package:health/screens/video_details/components/video_detail_item.dart';
import 'package:health/screens/video_details/components/video_tag_item.dart';
import 'package:health/screens/videos/components/body.dart';
import 'package:health/size_config.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsBody extends StatefulWidget {
  final video;

  const VideoDetailsBody({Key? key, this.video}) : super(key: key);
  @override
  _VideoDetailsBodyState createState() => _VideoDetailsBodyState(video: video);
}

class _VideoDetailsBodyState extends State<VideoDetailsBody> {
  final video;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  _VideoDetailsBodyState({this.video});

  @override
  void initState() {
    var videoFileName = video["video_uploaded_file_name"];

    _controller = VideoPlayerController.network(
      '$API_BASE_URL/videos/$videoFileName',
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['video_name'],
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w200),
                  ),
                  Text(
                    video['video_description'],
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w100),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      VideoDetailItem(
                          size: size,
                          label: video['video_length'].toStringAsFixed(1) +
                              ' ثانیه ',
                          icon: Icons.timer),
                      SizedBox(
                        width: 10,
                      ),
                      VideoDetailItem(
                          size: size,
                          label: video['video_exercise_time'] ?? '',
                          icon: Icons.sports_soccer),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i in video['video_affects'])
                        VideoTagItem(
                          label: i,
                        )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the VideoPlayerController has finished initialization, use
                        // the data it provides to limit the aspect ratio of the video.
                        return Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(1, 2))
                          ], borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,

                              // Use the VideoPlayer widget to display the video.
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        );
                      } else {
                        // If the VideoPlayerController is still initializing, show a
                        // loading spinner.
                        return Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 5,
                              ),
                              Text('در حال بارگذاری ویدیو...')
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          alignment: Alignment.topCenter,
                          tooltip: 'پخش ویدیو',
                          icon: Icon(
                            Icons.play_circle,
                            color: primaryColor,
                            size: getProportionateScreenWidth(36),
                          ),
                          onPressed: () {
                            _controller.play();
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          tooltip: 'توقف لحظه ای ویدیو',
                          icon: Icon(
                            Icons.pause_circle,
                            color: primaryColor,
                            size: getProportionateScreenWidth(36),
                          ),
                          onPressed: () {
                            _controller.pause();
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          tooltip: 'توقف کامل ویدیو',
                          icon: Icon(
                            Icons.stop_rounded,
                            color: primaryColor,
                            size: getProportionateScreenWidth(36),
                          ),
                          onPressed: () {
                            _controller.initialize();
                            _controller.play();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
