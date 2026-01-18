import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/add_permission/add_permission_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/components/custom_date_picker.dart';
import '../../../core/core.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  String? imagePath;
  late final TextEditingController dateController;
  late final TextEditingController reasonController;

  bool _isPicking = false;

  @override
  void initState() {
    dateController = TextEditingController();
    reasonController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => imagePath = pickedFile.path);
      }
    } finally {
      _isPicking = false;
    }
  }

  String formatDate(DateTime date) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    return dateFormatter.format(date);
  }

  void _submit() {
    final date = dateController.text.trim();
    final reason = reasonController.text.trim();

    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal wajib diisi'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keperluan wajib diisi'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lampiran wajib diisi'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    context.read<AddPermissionBloc>().add(
          AddPermissionEvent.addPermission(
            date: date,
            reason: reason,
            image: XFile(imagePath!),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Izin'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            // ===== HEADER CARD (Prisma vibe) =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Assets.icons.calendar.svg(
                        // kalau svg kamu support color, bisa aktifin:
                        // color: AppColors.primary,
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                  const SpaceWidth(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Form Izin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SpaceHeight(4),
                        Text(
                          'Isi tanggal, keperluan, dan lampiran pendukung.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SpaceHeight(18),

            // ===== FORM CARD =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.stroke),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomDatePicker(
                    label: 'Tanggal',
                    onDateSelected: (selectedDate) =>
                        dateController.text = formatDate(selectedDate),
                  ),
                  const SpaceHeight(16.0),
                  CustomTextField(
                    controller: reasonController,
                    label: 'Keperluan',
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            const SpaceHeight(18),

            // ===== ATTACHMENT CARD =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lampiran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SpaceHeight(6),
                  const Text(
                    'Upload foto pendukung (mis. surat dokter).',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  const SpaceHeight(14),

                  InkWell(
                    onTap: _isPicking ? null : _pickImage,
                    borderRadius: BorderRadius.circular(18),
                    child: imagePath == null
                        ? DottedBorder(
                            borderType: BorderType.RRect,
                            color: AppColors.primary.withOpacity(0.5),
                            radius: const Radius.circular(18.0),
                            dashPattern: const [8, 4],
                            strokeWidth: 1.2,
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Assets.icons.image.svg(
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
                                  ),
                                  const SpaceHeight(12),
                                  const Text(
                                    'Klik untuk pilih gambar',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SpaceHeight(4),
                                  Text(
                                    _isPicking ? 'Membuka galeri...' : 'PNG/JPG disarankan',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(
                                  File(imagePath!),
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () => setState(() => imagePath = null),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SpaceHeight(22),

            // ===== SUBMIT =====
            BlocConsumer<AddPermissionBloc, AddPermissionState>(
              listener: (context, state) {
                state.maybeWhen(
                  orElse: () {},
                  error: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  },
                  success: () {
                    dateController.clear();
                    reasonController.clear();
                    setState(() => imagePath = null);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Submit Izin berhasil'),
                        backgroundColor: AppColors.primary,
                      ),
                    );

                    context.pushReplacement(const MainPage());
                  },
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  orElse: () {
                    return SizedBox(
                      width: width,
                      child: Button.filled(
                        onPressed: _isPicking ? null : () => _submit(),
                        label: 'Kirim Permintaan',
                      ),
                    );
                  },
                );
              },
            ),

            const SpaceHeight(14),
          ],
        ),
      ),
    );
  }
}
