import 'package:flutter/material.dart';
import 'package:health/config/colors.dart';

class RangesBody extends StatelessWidget {
  final range;
  const RangesBody({Key? key, this.range}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SizedBox(
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: lightOrangeColor),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Center(
                  child: Text(
                    'جزئیات این شاخص بر اساس شاخص BMI شما می باشد',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              buildRangeItem(label: 'نام محدوده: ', value: range['range_name']),
              SizedBox(
                height: 10,
              ),
              buildRangeItem(
                  label: 'شروع محدوده:‌ ',
                  value: range['range_start'].toString()),
              SizedBox(
                height: 10,
              ),
              buildRangeItem(
                  label: 'پایان محدوده: ',
                  value: range['range_end'].toString()),
              SizedBox(
                height: 10,
              ),
              buildRangeItem(
                  label: 'وضعیت محدوده: ', value: range['range_status']),
              SizedBox(
                height: 10,
              ),
              buildRangeDescriptionItem(
                  label: 'توضیحات محدوده: ', value: range['range_description']),
            ],
          )),
    ));
  }

  Directionality buildRangeItem({required label, required value}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(value)
          ],
        ),
      ),
    );
  }

  Directionality buildRangeDescriptionItem({required label, required value}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Text(value)
          ],
        ),
      ),
    );
  }
}
