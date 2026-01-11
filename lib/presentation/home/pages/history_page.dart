import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_attendance_by_date/get_attendance_by_date_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/widget/history_attendace.dart';
import 'package:flutter_absensi_app/presentation/home/widget/history_location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/core.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    // current date format yyyy-MM-dd used intl package
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // get attendance by date
    context
        .read<GetAttendanceByDateBloc>()
        .add(GetAttendanceByDateEvent.getAttendanceByDate(currentDate));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          TableCalendar(
            firstDay: DateTime(2019, 1, 15),
            lastDay: DateTime.now().add(const Duration(days: 7)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            headerStyle: HeaderStyle(
              titleCentered: false,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: AppColors.black),
              weekendTextStyle: TextStyle(color: AppColors.black),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayTextStyle: const TextStyle(color: Colors.white),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              final selectedDate = DateFormat('yyyy-MM-dd').format(selectedDay);

              context.read<GetAttendanceByDateBloc>().add(
                    GetAttendanceByDateEvent.getAttendanceByDate(selectedDate),
                  );
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SpaceHeight(45.0),
          BlocBuilder<GetAttendanceByDateBloc, GetAttendanceByDateState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const SizedBox.shrink();
                },
                error: (message) {
                  return Center(
                    child: Text(message),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                empty: () {
                  return const Center(
                      child: Text('No attendance data available.'));
                },
                loaded: (attendance) {
                  // Pisahkan latlongIn menjadi latitude dan longitude
                  final latlongInParts = attendance.latlonIn!.split(',');
                  final latitudeIn = double.parse(latlongInParts.first);
                  final longitudeIn = double.parse(latlongInParts.last);

                  final latlongOutParts = attendance.latlonOut!.split(',');
                  final latitudeOut = double.parse(latlongOutParts.first);
                  final longitudeOut = double.parse(latlongOutParts.last);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      HistoryAttendance(
                        statusAbsen: 'Datang',
                        time: attendance.timeIn ?? '',
                        date: attendance.date.toString(),
                      ),
                      const SpaceHeight(10.0),
                      HistoryLocation(
                        latitude: latitudeIn,
                        longitude: longitudeIn,
                      ),
                      const SpaceHeight(25),
                      HistoryAttendance(
                        statusAbsen: 'Pulang',
                        isAttendanceIn: false,
                        time: attendance.timeOut ?? '',
                        date: attendance.date.toString(),
                      ),
                      const SpaceHeight(10.0),
                      HistoryLocation(
                        isAttendance: false,
                        latitude: latitudeOut,
                        longitude: longitudeOut,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
