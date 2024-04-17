import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../screens/registration/user_info.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'day_item.dart';
import 'month_item.dart';
import 'year_item.dart';
import 'util/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

typedef OnDateSelected = void Function(DateTime);

/// Creates a minimal, small profile calendar to select specific dates.
/// [initialDate] must not be [null], the same or after [firstDate] and
/// the same or before [lastDate]. [firstDate] must not be [null].
/// [lastDate] must not be null and the same or after [firstDate]
class CalendarTimeline extends StatefulWidget {
  CalendarTimeline({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.selectableDayPredicate,
    this.leftMargin = 0,
    this.dayColor,
    this.activeDayColor,
    required this.activeBackgroundDayColor,
    required this.nonActiveBackgroundDayColor,
    required this.activeMonthColor,
    this.monthColor,
    this.dotsColor,
    this.dayNameColor,
    this.shrink = false,
    this.locale,
    this.showYears = false,
  })  : assert(
          initialDate.difference(firstDate).inDays >= 0,
          'initialDate must be on or after firstDate',
        ),
        assert(
          !initialDate.isAfter(lastDate),
          'initialDate must be on or before lastDate',
        ),
        assert(
          !firstDate.isAfter(lastDate),
          'lastDate must be on or after firstDate',
        ),
        assert(
          selectableDayPredicate == null || selectableDayPredicate(initialDate),
          'Provided initialDate must satisfy provided selectableDayPredicate',
        ),
        assert(
          locale == null || dateTimeSymbolMap().containsKey(locale),
          "Provided locale value doesn't exist",
        ),
        super(key: key);
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final OnDateSelected onDateSelected;
  final double leftMargin;
  final Color? dayColor;
  final Color? activeDayColor;
  final Color activeBackgroundDayColor;
  final Color nonActiveBackgroundDayColor;
  final Color activeMonthColor;
  final Color? monthColor;
  final Color? dotsColor;
  final Color? dayNameColor;
  final bool shrink;
  final String? locale;

  /// If true, it will show a separate row for the years.
  /// It defaults to false
  final bool showYears;

  @override
  State<CalendarTimeline> createState() => _CalendarTimelineState();
}

class _CalendarTimelineState extends State<CalendarTimeline> {
  final ItemScrollController _controllerYear = ItemScrollController();
  final ItemScrollController _controllerMonth = ItemScrollController();
  final ItemScrollController _controllerDay = ItemScrollController();
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('weekSchedule').snapshots();
  int? _yearSelectedIndex;
  int? _monthSelectedIndex;
  int? _daySelectedIndex;
  late double _scrollAlignment;

  final List<DateTime> _years = [];
  final List<DateTime> _months = [];
  final List<DateTime> _days = [];
  late DateTime _selectedDate;

  late String _locale;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initCalendar();
  }

  @override
  void didUpdateWidget(CalendarTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != _selectedDate ||
        widget.showYears != oldWidget.showYears) {
      _initCalendar();
    }
  }

  /// Initializes the calendar. It will be executed every time a new date is selected
  void _initCalendar() {
    _locale = widget.locale ?? Localizations.localeOf(context).languageCode;
    initializeDateFormatting(_locale);
    _selectedDate = widget.initialDate;
    if (widget.showYears) {
      _generateYears();
      _selectedYearIndex();
      _moveToYearIndex(_yearSelectedIndex ?? 0);
    }
    _generateMonths(_selectedDate);
    _selectedMonthIndex();
    _moveToMonthIndex(_monthSelectedIndex ?? 0);
    _generateDays(_selectedDate);
    _selectedDayIndex();
    _moveToDayIndex(_daySelectedIndex ?? 0);
  }

  /// It will populate the [_years] list with the years between firstDate and lastDate
  void _generateYears() {
    _years.clear();
    var date = widget.firstDate;
    while (date.isBefore(widget.lastDate)) {
      _years.add(date);
      date = DateTime(date.year + 1);
    }
  }

  /// It will populate the [_months] list. If [widget.showYears] is true, it will add from January
  /// to December, unless the selected year is the [widget.firstDate.year] or the [widget.lastDate.year].
  /// In that case it will only from and up to the allowed months in [widget.firstDate] and [widget.lastDate].
  /// By default, when [widget.showYears] is false, it will add all months from [widget.firstDate] to
  /// [widget.lastDate] and all in between
  void _generateMonths(DateTime? selectedDate) {
    _months.clear();
    if (widget.showYears) {
      final month = selectedDate!.year == widget.firstDate.year
          ? widget.firstDate.month
          : 1;
      var date = DateTime(selectedDate.year, month);
      while (date.isBefore(DateTime(selectedDate.year + 1)) &&
          date.isBefore(widget.lastDate)) {
        _months.add(date);
        date = DateTime(date.year, date.month + 1);
      }
    } else {
      var date = DateTime(widget.firstDate.year, widget.firstDate.month);
      while (date.isBefore(widget.lastDate)) {
        _months.add(date);
        date = DateTime(date.year, date.month + 1);
      }
    }
  }

  /// It will populate the [_days] list with all the allowed days. Adding all days of the month
  /// when the [selectedDate.month] is not the first or the last in [widget.firstDate] or [widget.lastDate].
  /// In that case it will only show the allowed days from and up to the specified in [widget.firstDate]
  /// and [widget.lastDate]
  void _generateDays(DateTime? selectedDate) {
    _days.clear();
    for (var i = 1; i <= 31; i++) {
      final day = DateTime(selectedDate!.year, selectedDate.month, i);
      if (day.difference(widget.firstDate).inDays < 0) continue;
      if (day.month != selectedDate.month || day.isAfter(widget.lastDate)) {
        break;
      }
      _days.add(day);
    }
  }

  void _selectedYearIndex() {
    _yearSelectedIndex = _years.indexOf(
      _years.firstWhere((yearDate) => yearDate.year == _selectedDate.year),
    );
  }

  void _selectedMonthIndex() {
    if (widget.showYears) {
      _monthSelectedIndex = _months.indexOf(
        _months
            .firstWhere((monthDate) => monthDate.month == _selectedDate.month),
      );
    } else {
      _monthSelectedIndex = _months.indexOf(
        _months.firstWhere(
          (monthDate) =>
              monthDate.year == _selectedDate.year &&
              monthDate.month == _selectedDate.month,
        ),
      );
    }
  }

  void _selectedDayIndex() {
    _daySelectedIndex = _days.indexOf(
      _days.firstWhere((dayDate) => dayDate.day == _selectedDate.day),
    );
  }

  /// Scroll to index year
  void _moveToYearIndex(int index) {
    if (_controllerYear.isAttached) {
      _controllerYear.scrollTo(
        index: index,
        alignment: _scrollAlignment,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  /// Scroll to index month
  void _moveToMonthIndex(int index) {
    if (_controllerMonth.isAttached) {
      _controllerMonth.scrollTo(
        index: index,
        alignment: _scrollAlignment,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  /// Scroll to index day
  void _moveToDayIndex(int index) {
    if (_controllerDay.isAttached) {
      _controllerDay.scrollTo(
        index: index,
        alignment: _scrollAlignment,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  void _onSelectYear(int index) {
    // Move to selected year
    _yearSelectedIndex = index;
    _moveToYearIndex(index);

    // Reset month and day index
    _monthSelectedIndex = null;
    _daySelectedIndex = null;

    // Regenerate months and days
    final date = _years[index];
    if (widget.showYears) {
      _generateMonths(date);
      _moveToMonthIndex(0);
    }
    _generateDays(date);
    _moveToDayIndex(0);
    setState(() {});
  }

  void _onSelectMonth(int index) {
    // Move to selected month
    _monthSelectedIndex = index;
    _moveToMonthIndex(index);

    // Reset day index
    _daySelectedIndex = null;

    // Regenerate days
    _generateDays(_months[index]);
    _moveToDayIndex(0);
    setState(() {});
  }

  void _onSelectDay(int index) {
    // Move to selected day
    _daySelectedIndex = index;
    _moveToDayIndex(index);
    setState(() {});

    // Notify to callback
    _selectedDate = _days[index];
    widget.onDateSelected(_selectedDate);
  }

  bool _isSelectedDay(int index) =>
      _monthSelectedIndex != null &&
      (index == _daySelectedIndex || index == _indexOfDay(_selectedDate));

  int _indexOfDay(DateTime date) {
    try {
      return _days.indexOf(
        _days.firstWhere(
          (dayDate) =>
              dayDate.day == date.day &&
              dayDate.month == date.month &&
              dayDate.year == date.year,
        ),
      );
    } catch (_) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollAlignment =
        (widget.leftMargin) / (MediaQuery.of(context).size.width - 130);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showYears) _buildYearList(),
        _buildMonthList(),
        _divide(),
        _buildDayList(),
      ],
    );
  }

  /// Creates the row with all the years in the calendar. It will only show if
  /// [widget.showYears] is set to true. It is false by default
  Widget _buildYearList() {
    return SizedBox(
      key: const Key('ScrollableYearList'),
      height: 40,
      child: ScrollablePositionedList.builder(
        initialScrollIndex: _yearSelectedIndex ?? 0,
        initialAlignment: _scrollAlignment,
        itemScrollController: _controllerYear,
        padding: EdgeInsets.only(left: widget.leftMargin),
        scrollDirection: Axis.horizontal,
        itemCount: _years.length,
        itemBuilder: (BuildContext context, int index) {
          final currentDate = _years[index];
          final yearName = DateFormat.y(_locale).format(currentDate);

          return Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                YearItem(
                  isSelected: _yearSelectedIndex == index,
                  name: yearName,
                  onTap: () => _onSelectYear(index),
                  color: widget.monthColor,
                  small: false,
                  shrink: widget.shrink,
                ),
                if (index == _years.length - 1)
                  // Last element to take space to do scroll to left side
                  SizedBox(
                    width: MediaQuery.of(context).size.width -
                        widget.leftMargin -
                        (yearName.length * 10),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  /// Creates the row with all the months in the calendar. If [widget.showYears] is set to true
  /// it will only show the months allowed in the selected year. By default it will show all
  /// months in the calendar and the small version of [YearItem] for each year in between
  Widget _buildMonthList() {
    return SizedBox(
      height: 30,
      child: ScrollablePositionedList.builder(
        initialScrollIndex: _monthSelectedIndex ?? 0,
        initialAlignment: _scrollAlignment,
        itemScrollController: _controllerMonth,
        padding: EdgeInsets.only(left: widget.leftMargin),
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (BuildContext context, int index) {
          final currentDate = _months[index];
          final monthName = DateFormat.MMMM(_locale).format(currentDate);

          return Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.firstDate.year != currentDate.year &&
                    currentDate.month == 1 &&
                    !widget.showYears)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: YearItem(
                      name: DateFormat.y(_locale).format(currentDate),
                      color: widget.monthColor,
                      onTap: () {},
                      shrink: widget.shrink,
                    ),
                  ),
                MonthItem(
                  isSelected: _monthSelectedIndex == index,
                  name: monthName,
                  onTap: () => _onSelectMonth(index),
                  color: widget.monthColor,
                  shrink: widget.shrink,
                  activeColor: widget.activeMonthColor,
                ),
                if (index == _months.length - 1)
                  // Last element to take space to do scroll to left side
                  SizedBox(
                    width: MediaQuery.of(context).size.width -
                        widget.leftMargin -
                        (monthName.length * 10),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  _onAlertWithCustomContentPressed(
      {required BuildContext context, required String data}) {
    Alert(
        style: const AlertStyle(
            backgroundColor: Colors.white,
            titlePadding: EdgeInsets.symmetric(vertical: 20)),
        context: context,
        title: "Guideline",
        content: Text(
          data.replaceAll('. ', '.\n\n'),
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        buttons: []).show();
  }

  Widget _buildDayList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimationWidget.inkDrop(
            color: const Color.fromARGB(255, 66, 104, 250),
            size: 30,
          ); // Show a loading indicator if data is not available yet.
        }

        for (var document in snapshot.data!.docs) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          UserInformation.weekSchedule[document.id] = data;
        }

        final currentDay =
            DateFormat.E(_locale).format(_selectedDate).capitalize().length > 3
                ? DateFormat.E(_locale)
                    .format(_selectedDate)
                    .capitalize()
                    .substring(0, 3)
                : DateFormat.E(_locale).format(_selectedDate).capitalize();

        String text = (UserInformation.weekSchedule[currentDay]!['active'])
            ? '$currentDay \n\n${UserInformation.weekSchedule[currentDay]!['detail']}'
            : 'Not Scheduled';
        return Column(
          children: [
            SizedBox(
              key: const Key('ScrollableDayList'),
              height: 90,
              child: ScrollablePositionedList.builder(
                itemScrollController: _controllerDay,
                initialScrollIndex: _daySelectedIndex ?? 0,
                initialAlignment: 0,
                // (_days.indexOf(_selectedDate) == 0) ? 0 : _scrollAlignment,
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                padding: EdgeInsets.only(left: widget.leftMargin, right: 6),
                itemBuilder: (BuildContext context, int index) {
                  final currentDay = _days[index];
                  final dayName =
                      DateFormat.E(_locale).format(currentDay).capitalize();
                  final shortName =
                      dayName.length > 3 ? dayName.substring(0, 3) : dayName;

                  return Row(
                    children: <Widget>[
                      DayItem(
                        isSelected: _isSelectedDay(index),
                        dayNumber: currentDay.day,
                        shortName: shortName,
                        onTap: () => _onSelectDay(index),
                        available: widget.selectableDayPredicate == null ||
                            widget.selectableDayPredicate!(currentDay),
                        dayColor: widget.dayColor,
                        activeDayColor: widget.activeDayColor,
                        activeDayBackgroundColor:
                            widget.activeBackgroundDayColor,
                        nonActiveDayBackgroundColor:
                            (UserInformation.weekSchedule[shortName]!['active'])
                                ? Color.fromARGB(
                                    int.parse(UserInformation
                                        .weekSchedule[shortName]!['color']
                                        .split(',')[0]),
                                    int.parse(UserInformation
                                        .weekSchedule[shortName]!['color']
                                        .split(',')[1]),
                                    int.parse(UserInformation
                                        .weekSchedule[shortName]!['color']
                                        .split(',')[2]),
                                    int.parse(UserInformation
                                        .weekSchedule[shortName]!['color']
                                        .split(',')[3]),
                                  )
                                : widget.nonActiveBackgroundDayColor,
                        dotsColor: widget.dotsColor,
                        dayNameColor: widget.dayNameColor,
                        shrink: widget.shrink,
                        scheduled: (UserInformation
                            .weekSchedule[shortName]!['active']),
                        scheduledDay: (UserInformation
                                .weekSchedule[shortName]!['active'])
                            ? UserInformation.weekSchedule[shortName]!['type']
                                .toString()
                                .capitalize()
                            : '',
                      ),
                      if (index == _days.length - 1)
                        // Last element to take space to do scroll to left side
                        SizedBox(
                          width: MediaQuery.of(context).size.width -
                              widget.leftMargin -
                              65,
                        )
                    ],
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Divider(
                height: 2,
                color: Colors.black,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              height: (UserInformation.weekSchedule[currentDay]!['active'])
                  ? 150
                  : 100,
              width: MediaQuery.of(context).size.width,
              child: (UserInformation.weekSchedule[currentDay]!['active'])
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black26),
                              ),
                              child: const Text(
                                'See Guidelines',
                                style: TextStyle(color: Colors.white70),
                              ),
                              onPressed: () => setState(() {
                                _onAlertWithCustomContentPressed(
                                    context: context,
                                    data: UserInformation.weekSchedule[
                                        currentDay]!['guideline']);
                              }),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
