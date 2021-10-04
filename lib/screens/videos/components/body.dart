import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/config/constants.dart';
import 'package:health/models/Video.dart';
import 'package:health/screens/home_page/components/body.dart';
import 'package:health/screens/video_details/video_details_screen.dart';
import 'package:health/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VideoBody extends StatefulWidget {
  const VideoBody({Key? key}) : super(key: key);

  @override
  _VideoBodyState createState() => _VideoBodyState();
}

class _VideoBodyState extends State<VideoBody> {
  late List videosList = [];

  var loading = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

  Future<void> fetchVideos({token}) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
        Uri.parse('https://myhealth-back.iran.liara.run/api/videos/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': token
        });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = responseBody['result']['videos'];

      setState(() {
        for (Map i in data) {
          videosList.add(i);
        }

        loading = false;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.

      loading = false;
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    _getAuthToken()
        .then((value) => {
              if (value.isNotEmpty) {fetchVideos(token: value)}
            })
        .catchError((err) => {});

    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.redAccent.withOpacity(0.3)),
              child: Center(
                child: Text(
                  'این ویدیوها بر اساس شاخص BMI شما تهیه شده است',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2 / 3,
                              crossAxisSpacing: 20.0,
                              mainAxisSpacing: 20.0,
                            ),
                            itemCount: videosList.length,
                            itemBuilder: (context, index) {
                              return VideoItem(
                                video: videosList[index],
                                press: () {
                                  Navigator.of(context).push(
                                      _createRoute(video: videosList[index]));
                                },
                              );
                            },
                          )))
          ],
        ),
      ),
    );
  }
}

Route _createRoute({video}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => VideoDetailsScreen(
      video: video,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class VideoItem extends StatelessWidget {
  const VideoItem({
    Key? key,
    required this.video,
    required this.press,
  }) : super(key: key);

  final video;
  final VoidCallback press;
  @override
  Widget build(BuildContext context) {
    var thumbFileName = video['video_thmubnail'];
    return InkWell(
      onTap: press,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(-1, 2))
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Image.network(
                  '$API_BASE_URL/thumbnails/$thumbFileName',
                  width: double.infinity,
                  height: SizeConfig.screenHeight * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      video['video_name'],
                      style: TextStyle(),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.timer),
                        Text(video['video_length'].toStringAsFixed(1)),
                        SizedBox(
                          width: 5,
                        ),
                        Text('ثانیه')
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
