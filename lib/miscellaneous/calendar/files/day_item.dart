import 'package:flutter/material.dart';

/// Creates a Widget representing the day.
class DayItem extends StatelessWidget {
  const DayItem({
    Key? key,
    required this.dayNumber,
    required this.shortName,
    required this.onTap,
    this.isSelected = false,
    this.dayColor,
    this.activeDayColor,
    this.activeDayBackgroundColor,
    this.nonActiveDayBackgroundColor,
    this.available = true,
    this.dotsColor,
    this.dayNameColor,
    this.shrink = false,
    required this.scheduled,
    required this.scheduledDay,
  }) : super(key: key);
  final int dayNumber;
  final String shortName;
  final bool isSelected;
  final Function onTap;
  final Color? dayColor;
  final Color? activeDayColor;
  final Color? activeDayBackgroundColor;
  final bool available;
  final Color? dotsColor;
  final Color? dayNameColor;
  final bool shrink;

  final Color? nonActiveDayBackgroundColor;
  final bool scheduled;
  final String scheduledDay;

  GestureDetector _buildDay(BuildContext context) {
    final textStyle = TextStyle(
      color: available
          ? dayColor ?? Theme.of(context).colorScheme.secondary
          : dayColor?.withOpacity(0.5) ??
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
      fontSize: shrink ? 14 : 32,
      fontWeight: FontWeight.normal,
    );
    final selectedStyle = TextStyle(
      color: activeDayColor ?? Colors.white,
      fontSize: shrink ? 14 : 32,
      fontWeight: FontWeight.bold,
      height: 0.8,
    );

    return GestureDetector(
      onTap: available ? onTap as void Function()? : null,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        // : const EdgeInsets.on(horizontal: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: scheduled
                    ? nonActiveDayBackgroundColor
                    : activeDayBackgroundColor ??
                        Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              )
            : BoxDecoration(
                color: nonActiveDayBackgroundColor ??
                    Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
        height: isSelected ? 90 : 70,
        width: isSelected ? 60 : 60,
        child: Column(
          children: <Widget>[
            if (isSelected) ...[
              SizedBox(height: shrink ? 6 : 7),
              if (!shrink) _buildDots(),
              SizedBox(height: shrink ? 9 : 12),
            ] else
              SizedBox(height: shrink ? 10 : 14),
            Text(
              dayNumber.toString(),
              style: isSelected ? selectedStyle : textStyle,
            ),
            if (isSelected)
              Text(
                '$shortName\n$scheduledDay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: shrink ? 8 : 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    final dot = Container(
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        color: dotsColor ?? activeDayColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [dot, dot],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDay(context);
  }
}
