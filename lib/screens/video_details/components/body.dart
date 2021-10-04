import 'package:flutter/material.dart';
import 'package:health/config/constants.dart';

import 'package:health/screens/video_details/components/video_detail_item.dart';
import 'package:health/screens/video_details/components/video_tag_item.dart';
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

    _controller.play();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,

                            // Use the VideoPlayer widget to display the video.
                            child: VideoPlayer(_controller),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_circle),
                        onPressed: () {
                          _controller.play();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.pause_circle),
                        onPressed: () {
                          _controller.pause();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.stop_rounded),
                        onPressed: () {
                          _controller.initialize();
                          _controller.play();
                        },
                      ),
                    ],
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
