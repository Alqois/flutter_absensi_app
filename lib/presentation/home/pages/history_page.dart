import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_attendance_by_date/get_attendance_by_date_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/widget/history_attendance.dart';
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

  // ===== DOT INDICATOR STORAGE =====
  final Map<DateTime, List<String>> _events = {};

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<String> _getEventsForDay(DateTime day) {
    return _events[_normalize(day)] ?? const [];
  }

  void _markDayHasAttendance(DateTime day) {
    final key = _normalize(day);
    _events.putIfAbsent(key, () => ['attendance']);
  }

  // ====== PARSER LATLON (AUTO SWAP) ======
  ({double lat, double lon}) _parseLatLon(String? raw) {
    if (raw == null || raw.trim().isEmpty) return (lat: 0, lon: 0);

    final parts = raw.split(',');
    if (parts.length < 2) return (lat: 0, lon: 0);

    final a = double.tryParse(parts[0].trim()) ?? 0;
    final b = double.tryParse(parts[1].trim()) ?? 0;

    // asumsi awal: "lat,lon"
    double lat = a;
    double lon = b;

    final latOk = lat >= -90 && lat <= 90;
    final lonOk = lon >= -180 && lon <= 180;

    if (latOk && lonOk) return (lat: lat, lon: lon);

    // coba swap: "lon,lat"
    final lat2 = b;
    final lon2 = a;

    final lat2Ok = lat2 >= -90 && lat2 <= 90;
    final lon2Ok = lon2 >= -180 && lon2 <= 180;

    if (lat2Ok && lon2Ok) return (lat: lat2, lon: lon2);

    // kalau masih aneh, balikin default biar gak crash
    return (lat: lat, lon: lon);
  }

  // ====== FORMAT DATE (hilangin jam 00:00:00.000) ======
  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return '-';

      if (dateValue is DateTime) {
        return DateFormat('yyyy-MM-dd').format(dateValue);
      }

      // kalau dari API String: "2026-01-15 00:00:00.000" atau ISO
      final s = dateValue.toString();
      final dt = DateTime.tryParse(s);
      if (dt != null) {
        return DateFormat('yyyy-MM-dd').format(dt);
      }

      // fallback: ambil sebelum spasi
      if (s.contains(' ')) return s.split(' ').first;
      return s;
    } catch (_) {
      return dateValue.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalize(DateTime.now());

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    context
        .read<GetAttendanceByDateBloc>()
        .add(GetAttendanceByDateEvent.getAttendanceByDate(today));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3F6FB),
              Color(0xFFEAF0FA),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            BlocListener<GetAttendanceByDateBloc, GetAttendanceByDateState>(
              listener: (context, state) {
                state.maybeWhen(
                  loaded: (_) {
                    final day = _selectedDay ?? _normalize(_focusedDay);
                    setState(() => _markDayHasAttendance(day));
                  },
                  orElse: () {},
                );
              },
              child: _CalendarCard(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = _normalize(selectedDay);
                    _focusedDay = focusedDay;
                  });

                  final date = DateFormat('yyyy-MM-dd').format(selectedDay);
                  context.read<GetAttendanceByDateBloc>().add(
                        GetAttendanceByDateEvent.getAttendanceByDate(date),
                      );
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Riwayat Absensi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 14),

            BlocBuilder<GetAttendanceByDateBloc, GetAttendanceByDateState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  empty: () => _EmptyState(),
                  error: (msg) => _ErrorState(msg),
                  loaded: (attendance) {
                    final inLL = _parseLatLon(attendance.latlonIn);
                    final outLL = _parseLatLon(attendance.latlonOut);

                    final prettyDate = _formatDate(attendance.date);

                    return Column(
                      children: [
                        HistoryAttendance(
                          statusAbsen: 'Datang',
                          time: attendance.timeIn ?? '-',
                          date: prettyDate,
                        ),
                        const SizedBox(height: 10),
                        HistoryLocation(
                          latitude: inLL.lat,
                          longitude: inLL.lon,
                        ),
                        const SizedBox(height: 22),
                        HistoryAttendance(
                          statusAbsen: 'Pulang',
                          isAttendanceIn: false,
                          time: attendance.timeOut ?? '-',
                          date: prettyDate,
                        ),
                        const SizedBox(height: 10),
                        HistoryLocation(
                          isAttendance: false,
                          latitude: outLL.lat,
                          longitude: outLL.lon,
                        ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CALENDAR CARD (PANAH BERFUNGSI + DOT) =================

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(DateTime focusedDay) onPageChanged;
  final List<String> Function(DateTime day) eventLoader;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.10),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: TableCalendar(
          firstDay: DateTime(2019, 1, 1),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          eventLoader: eventLoader,

          rowHeight: 46,
          daysOfWeekHeight: 22,

          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            leftChevronVisible: true,
            rightChevronVisible: true,
            leftChevronIcon: const _CalendarArrow(icon: Icons.chevron_left),
            rightChevronIcon: const _CalendarArrow(icon: Icons.chevron_right),
            titleTextStyle: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),

          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w700,
            ),
            weekendStyle: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),

          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: const EdgeInsets.all(6),
            defaultTextStyle: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
            weekendTextStyle: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
            todayTextStyle: const TextStyle(color: Colors.white),
            selectedTextStyle: const TextStyle(color: Colors.white),
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),

          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Positioned(
                bottom: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
        ),
      ),
    );
  }
}

class _CalendarArrow extends StatelessWidget {
  final IconData icon;
  const _CalendarArrow({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.grey),
    );
  }
}

// ================= STATES =================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          'Tidak ada data absensi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.grey),
    );
  }
}
