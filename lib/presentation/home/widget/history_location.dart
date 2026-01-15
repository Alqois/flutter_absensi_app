import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/core.dart';

class HistoryLocation extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool isAttendance; // true: datang, false: pulang

  final String placeLabel;
  final String statusText;

  const HistoryLocation({
    super.key,
    required this.latitude,
    required this.longitude,
    this.isAttendance = true,
    this.placeLabel = 'Kantor',
    this.statusText = 'Sesuai spot Absensi',
  });

  Future<void> _openMaps() async {
    final lat = latitude;
    final lon = longitude;

    // Native intent Android (geo)
    final geoUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon');

    // Web: langsung center + zoom (lebih akurat daripada search)
    final googleWeb = Uri.parse('https://www.google.com/maps/@$lat,$lon,18z');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      if (await canLaunchUrl(googleWeb)) {
        await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
        return;
      }

      await launchUrl(googleWeb, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Open maps failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isAttendance ? const Color(0xFF0B2A55) : const Color(0xFFB83333);
    final soft = Colors.white.withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.place_rounded, color: Colors.white.withOpacity(0.95)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusChip(text: statusText),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  _KVRow(
                    label: 'Longitude',
                    value: longitude.toStringAsFixed(6),
                  ),
                  const SizedBox(height: 10),
                  _KVRow(
                    label: 'Latitude',
                    value: latitude.toStringAsFixed(6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text(
                  'Lihat di Peta',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white.withOpacity(0.16),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.white.withOpacity(0.14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label;
  final String value;
  const _KVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  const _StatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
