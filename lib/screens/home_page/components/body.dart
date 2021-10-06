import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/config/constants.dart';
import 'package:health/screens/diets/diets_screen.dart';
import 'package:health/screens/ranges/ranges_screen.dart';
import 'package:health/screens/video_details/components/video_tag_item.dart';
import 'package:health/screens/video_details/video_details_screen.dart';
import 'package:health/screens/videos/videos_screen.dart';
import 'package:health/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:http/http.dart' as http;
import 'package:snack/snack.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({Key? key}) : super(key: key);

  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Attributes
  Map<String, dynamic> userObject = {};
  Map<String, dynamic> rangeObject = {};
  late List videosList = [];

  double _value = 10;
  bool loadingVideos = false;
  bool loading = false;

  // Functions
  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

  Future<void> fetchUserData({token}) async {
    setState(() {
      loading = true;
    });
    final http.Response response = await http.get(
      Uri.parse(API_URL + '/users/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
    );

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var user = responseBody['result']['user'];
      var range = responseBody['result']['range'];

      setState(() {
        userObject.addAll(user);
        rangeObject.addAll(range);
        _value = double.parse(user['user_bmi']);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      SnackBar(
        content: Row(
          children: [Text(responseBody['errors'][0]['message'])],
        ),
      ).show(context);
    }
  }

  Future<void> fetchVideos({token}) async {
    setState(() {
      loadingVideos = true;
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

        loadingVideos = false;
      });
    } else {
      setState(() {
        loadingVideos = false;
      });
      throw Exception('Failed to load album');
    }
  }

  initState() {
    super.initState();

    setState(() {
      loading = true;
      loadingVideos = true;
    });
    _getAuthToken()
        .then((token) => {
              if (token.isNotEmpty)
                {fetchVideos(token: token), fetchUserData(token: token)}
            })
        .catchError((err) => {});
  }

  String userDefaultProfile() {
    var defaultManProfileImage =
        API_BASE_URL + '/thumbnails/' + 'Okwd0n-1633456912460.png';

    var defaultWomanProfileImage =
        API_BASE_URL + '/thumbnails/' + 'OAtZVi-1633456739151.png';

    return userObject['user_gender'] == 1
        ? defaultWomanProfileImage
        : defaultManProfileImage;
  }

  @override
  Widget build(BuildContext context) {
    var status = !loading ? rangeObject['range_status'] : 'نامشخص';
    var profileImageLink = !loading ? userObject['user_profile_image'] : '';
    var rangeStatus = 'وضعیت: ' + status;

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgLightColor,
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'سلامت من',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: !loading && !loadingVideos
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: SizeConfig.screenWidth * 0.05,
                              backgroundImage: NetworkImage(
                                  userObject['user_profile_image'] != null
                                      ? '$API_BASE_URL/profiles/$profileImageLink'
                                      : userDefaultProfile(),
                                  scale: 1)),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سلام،',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              !loading
                                  ? Text(
                                      userObject['user_name'] ?? '',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w300),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'شاخص توده بدنی (BMI) شما',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: SfSlider(
                                min: 0.0,
                                max: 100.0,
                                value: _value,
                                interval: 3,
                                activeColor:
                                    double.parse(userObject['user_bmi']) > 25
                                        ? redColor
                                        : primaryColor,
                                inactiveColor:
                                    double.parse(userObject['user_bmi']) > 25
                                        ? redColor.withOpacity(0.3)
                                        : primaryColor.withOpacity(0.3),
                                minorTicksPerInterval: 1,
                                onChanged: (dynamic value) {},
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color:
                                          double.parse(userObject['user_bmi']) >
                                                  25
                                              ? redColor
                                              : primaryColor),
                                  child: Text(
                                    'شاخص شما: ' + userObject['user_bmi'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color:
                                          double.parse(userObject['user_bmi']) >
                                                  25
                                              ? redColor
                                              : primaryColor),
                                  child: Text(
                                    rangeStatus,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      _rangeDetailsRoute(range: rangeObject));
                                },
                                child: Text(
                                  'توضیحات بیشتر',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(_videoScreenRoute());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: orangeColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Icon(
                                        Icons.sports_basketball_outlined,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('تمرینات ورزشی',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15))
                                  ],
                                ),
                              ),
                            ),
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(_dietCreateRoute());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: redColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Icon(
                                        Icons.food_bank_outlined,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('برنامه غذایی',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15))
                                  ],
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('ویدیو پیشنهادی',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      SizedBox(
                        height: 10,
                      ),
                      !loadingVideos
                          ? Container(
                              height: SizeConfig.screenWidth > 420
                                  ? getProportionateScreenWidth(300)
                                  : getProportionateScreenWidth(350),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: videosList.length,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        VideoBox(
                                            size: size,
                                            video: videosList[index],
                                            press: () => Navigator.of(context)
                                                .push(_videoDetailsScreenRoute(
                                                    video: videosList[index]))),
                                      ],
                                    );
                                  }))
                          : CircularProgressIndicator()
                    ],
                  )
                : Container(
                    height: SizeConfig.screenHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text('کمی صبر کنید...')
                      ],
                    )),
          ),
        )),
      ),
    );
  }
}

Route _videoDetailsScreenRoute({video}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        VideoDetailsScreen(video: video),
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

Route _videoScreenRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => VideosScreen(),
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

Route _dietCreateRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const DietsScreen(),
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

class VideoBox extends StatelessWidget {
  const VideoBox({
    Key? key,
    required this.size,
    required this.video,
    required this.press,
  }) : super(key: key);

  final Size size;
  final video;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    var thumbnailFileName = video['video_thmubnail'];

    return InkWell(
      onTap: press,
      child: Container(
        width:
            SizeConfig.screenWidth > 420 ? size.width * 0.4 : size.width * 0.6,
        height: SizeConfig.screenWidth > 420
            ? size.width * 0.50
            : size.height * 0.45,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 4, color: Colors.grey.withOpacity(0.3))
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: SizeConfig.screenWidth > 420
                  ? size.width * 0.17
                  : size.width * 0.35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  image: DecorationImage(
                      image: NetworkImage(
                        '$API_BASE_URL/thumbnails/$thumbnailFileName',
                      ),
                      fit: BoxFit.cover)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    video['video_name'],
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    video['video_description'] + video['video_description'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 30,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: video['video_affects'].length,
                              itemBuilder: (ctx, index) {
                                return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: bgButtonYellow.withOpacity(0.4)),
                                    margin:
                                        const EdgeInsets.only(top: 3, left: 5),
                                    child: Text(video['video_affects'][index]));
                              }),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 30,
                    child: Wrap(
                      children: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.fitness_center,
                                color: bgDarkColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.only(top: 7),
                                child: Text(
                                  video['video_exercise_time'].toString(),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.timer_outlined,
                                color: bgDarkColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.only(top: 7),
                                child: Text(
                                  video['video_length'].toStringAsFixed(1),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: Text(
                                'ثانیه',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Route _rangeDetailsRoute({range}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        RangesScreen(range: range),
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
