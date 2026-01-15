import 'package:flutter/material.dart';
import '../../../core/core.dart';

class HistoryAttendance extends StatelessWidget {
  final String statusAbsen; // Datang / Pulang
  final String time;
  final String date;
  final bool isAttendanceIn;

  const HistoryAttendance({
    super.key,
    required this.statusAbsen,
    required this.time,
    required this.date,
    this.isAttendanceIn = true,
  });

  @override
  Widget build(BuildContext context) {
    // Prisma-ish: Datang = navy/primary, Pulang = red-ish tapi tetap soft
    final bgStart = isAttendanceIn
        ? AppColors.primary
        : const Color(0xFFE94B4B); // beda dari tutor (bukan merah flat)
    final bgEnd = isAttendanceIn
        ? const Color(0xFF0B2A55) // navy lebih dalam
        : const Color(0xFFB83333);

    final label = 'Absensi $statusAbsen';
    final subLabel = 'Kantor';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgStart, bgEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent strip biar beda dari tutor
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            subLabel,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniChip(
                            text: isAttendanceIn ? 'IN' : 'OUT',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (time.isEmpty) ? '-' : time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  const _MiniChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
