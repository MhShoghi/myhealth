import 'package:flutter/material.dart';

class DietDetailsBody extends StatelessWidget {
  final diet;

  const DietDetailsBody({Key? key, this.diet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var breakfast = diet['diet_plan']['plan_breakfast'];
    var lunch = diet['diet_plan']['plan_lunch'];
    var dinner = diet['diet_plan']['plan_dinner'];
    var snack = diet['diet_plan']['plan_snack'];

    return SingleChildScrollView(
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                Text(
                  diet['diet_name'],
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  diet['diet_description'],
                  softWrap: true,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w200),
                ),
                SizedBox(
                  height: 18,
                ),
                DietItem(
                  label: 'صبحانه',
                  img: 'breakfast',
                  plan: breakfast,
                  color: Colors.blue.withOpacity(0.4),
                ),
                SizedBox(
                  height: 10,
                ),
                DietItem(
                  label: 'ناهار',
                  img: 'lunch',
                  plan: lunch,
                  color: Colors.green.withOpacity(0.4),
                ),
                SizedBox(
                  height: 10,
                ),
                DietItem(
                  label: 'شام',
                  img: 'dinner',
                  plan: dinner,
                  color: Colors.red.withOpacity(0.4),
                ),
                SizedBox(
                  height: 10,
                ),
                DietItem(
                  label: 'میان وعده',
                  img: 'snack',
                  plan: snack,
                  color: Colors.purple.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DietItem extends StatelessWidget {
  const DietItem({
    Key? key,
    required this.color,
    required this.label,
    required this.plan,
    required this.img,
  }) : super(key: key);

  final Color color;
  final String label;
  final String plan;
  final String img;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)
          ]),
      child: Row(
        children: [
          Flexible(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Center(
                child: Text(
                  plan,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                          child: Image.asset(
                        'assets/images/$img.png',
                        scale: 15,
                      )),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                      )
                    ])),
          )
        ],
      ),
    );
  }
}
