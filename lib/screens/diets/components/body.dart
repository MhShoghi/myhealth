import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';
import 'package:health/screens/diet_details/diet_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../config/constants.dart';

class DietsBody extends StatefulWidget {
  @override
  _DietsBodyState createState() => _DietsBodyState();
}

class _DietsBodyState extends State<DietsBody> {
  late List dietList = [];

  var loading = true;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('auth_token').toString();
  }

  Future<void> fetchDiets({token}) async {
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse('$API_URL/diets/me'), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': token
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final data = responseBody['result']['diets'];

      setState(() {
        for (Map i in data) {
          dietList.add(i);
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
              if (value.isNotEmpty) {fetchDiets(token: value)}
            })
        .catchError((err) => {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.orangeAccent.withOpacity(0.5)),
                child: Center(
                  child: Text(
                    'این برنامه غذایی بر اساس شاخص BMI شما نوشته شده است',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              !loading
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: dietList.length,
                          itemBuilder: (ctx, index) {
                            return buildPlanItem(
                                label: dietList[index]['diet_name'],
                                onPressed: () {
                                  Navigator.of(context).push(
                                      _dietDetailsRoute(diet: dietList[index]));
                                });
                          }),
                    )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Container buildPlanItem({label, onPressed}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
                Flexible(
                  flex: 3,
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Icon(
                  Icons.restaurant_menu,
                  color: primaryColor,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Route _dietDetailsRoute({diet}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        DietDetailsScreen(diet: diet),
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
