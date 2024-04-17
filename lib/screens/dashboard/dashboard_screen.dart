import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../miscellaneous/colors.dart';
import '../../miscellaneous/notification_api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../miscellaneous/calendar/calendar_timeline.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  static const id = 'Dashboard_screen';
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now().add(const Duration(days: 0));
  }

  Widget _divide() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Divider(
        height: 2,
        color: Colors.black,
      ),
    );
  }

  String data = '';
  _onAlertWithCustomContentPressed(context, {required VoidCallback fun}) {
    Alert(
        context: context,
        title: "Set Reminder",
        style: const AlertStyle(
            backgroundColor: Colors.white,
            titlePadding: EdgeInsets.symmetric(vertical: 20)),
        content: Column(
          children: <Widget>[
            TextField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.black54),
                labelText: 'Reminder',
              ),
              onChanged: (value) {
                data = value;
              },
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: fun,
            child: const Text(
              "Set",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 207, 149),
        toolbarHeight: 70,
        leading: Hero(
          tag: 'logo',
          child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: Image.asset('images/logo.png')),
        ),
        titleSpacing: 20,
        titleTextStyle: const TextStyle(fontSize: 30, color: Colors.white),
        title: const Text("Dashboard"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Calendar',
                style: TextStyle(
                    fontSize: 25, color: colorTwo, fontWeight: FontWeight.bold),
              ),
            ),
            _divide(),
            CalendarTimeline(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 7)),
              onDateSelected: (date) => setState(() => _selectedDate = date),
              leftMargin: 20,
              monthColor: Colors.black45,
              dayColor: Colors.black54,
              dayNameColor: const Color(0xFF333A47),
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.black45,
              nonActiveBackgroundDayColor: Colors.black12,
              activeMonthColor: const Color(0xFF4268F9),
              dotsColor: const Color(0xFF333A47),
              selectableDayPredicate: (date) => date.day != 23,
              locale: 'en',
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: TextButton(
                  onPressed: () {
                    picker.DatePicker.showDateTimePicker(context,
                        minTime:
                            DateTime.now().subtract(const Duration(seconds: 1)),
                        maxTime: DateTime.now().add(const Duration(days: 7)),
                        showTitleActions: true,
                        onChanged: (date) {}, onConfirm: (date) {
                      _onAlertWithCustomContentPressed(context, fun: () {
                        NotificationApi.showScheduledNotification(
                            title: 'My Shire Reminder',
                            body: data,
                            date: DateTime.now().add(Duration(
                              days: date.day - DateTime.now().day,
                              hours: date.hour - DateTime.now().hour,
                              minutes: date.minute - DateTime.now().minute,
                            )));
                      });
                    },
                        currentTime: DateTime.now(),
                        locale: picker.LocaleType.en);
                  },
                  child: const Text(
                    'Add a Reminder',
                    style: TextStyle(color: Colors.blue),
                  ),
                )),
              ),
            ),
            _divide(),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF00CD94)),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => setState(() => _resetSelectedDate()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
