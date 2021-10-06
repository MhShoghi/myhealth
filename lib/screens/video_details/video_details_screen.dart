import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/video_details/components/body.dart';

class VideoDetailsScreen extends StatefulWidget {
  final video;
  const VideoDetailsScreen({Key? key, this.video}) : super(key: key);

  @override
  _VideoDetailsScreenState createState() =>
      _VideoDetailsScreenState(video: video);
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  final video;

  _VideoDetailsScreenState({this.video});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLightColor,
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        leading: IconButton(
          disabledColor: Colors.red,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
      ),
      body: VideoDetailsBody(video: video),
    );
  }
}
