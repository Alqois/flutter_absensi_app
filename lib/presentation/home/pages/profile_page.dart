import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/auth_response_model.dart';
import 'package:flutter_absensi_app/presentation/home/pages/change_password_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/core.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authLocal = AuthLocalDataSource();

  AuthResponseModel? _auth;
  bool _loading = true;

  static const _photoKey = 'profile_photo_path';
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = await _authLocal.getAuthData();
    final pref = await SharedPreferences.getInstance();
    final photo = pref.getString(_photoKey);

    if (!mounted) return;
    setState(() {
      _auth = auth;
      _photoPath = photo;
      _loading = false;
    });
  }

  Future<void> _pickAndSavePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final ext = picked.path.split('.').last;
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savedFile = await File(picked.path).copy('${dir.path}/$fileName');

      final pref = await SharedPreferences.getInstance();
      await pref.setString(_photoKey, savedFile.path);

      if (!mounted) return;
      setState(() => _photoPath = savedFile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal pilih foto: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Pilih dari galeri'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndSavePhoto();
                  },
                ),
                if (_photoPath != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.red),
                    title: const Text(
                      'Hapus foto',
                      style: TextStyle(color: AppColors.red),
                    ),
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      await pref.remove(_photoKey);
                      if (!mounted) return;
                      setState(() => _photoPath = null);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(user),
                const SizedBox(height: 16),

                _sectionTitle('Biodata'),
                _card(
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.badge_outlined,
                        title: 'Nama',
                        value: _safe(user?.name),
                        onTap: () => _openEditFieldSheet(
                          title: 'Nama',
                          initialValue: user?.name ?? '',
                          onSave: (val) async {
                            if (_auth == null) return;
                            final updatedUser = user!.copyWith(name: val);
                            await _authLocal.updateAuthData(updatedUser);
                            await _init();
                          },
                        ),
                      ),
                      _dividerSoft(),
                      _infoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: _safe(user?.email),
                        // biasanya email gak diedit
                      ),
                      _dividerSoft(),
                      _infoTile(
                        icon: Icons.phone_outlined,
                        title: 'No. HP',
                        value: _safe(user?.phone),
                        onTap: () => _openEditFieldSheet(
                          title: 'No. HP',
                          initialValue: user?.phone ?? '',
                          keyboardType: TextInputType.phone,
                          onSave: (val) async {
                            if (_auth == null) return;
                            final updatedUser = user!.copyWith(phone: val);
                            await _authLocal.updateAuthData(updatedUser);
                            await _init();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _sectionTitle('Lainnya'),
                _card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Ganti Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _header(dynamic user) {
    final name = _safe(user?.name);
    final email = _safe(user?.email);

    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.grey.withOpacity(0.2),
                  backgroundImage: _photoPath != null
                      ? FileImage(File(_photoPath!))
                      : null,
                  child: _photoPath == null
                      ? const Icon(Icons.person, size: 34)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _showPhotoSheet,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _safe(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: child,
    );
  }

  Widget _dividerSoft() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.grey.withOpacity(0.15),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: onTap != null ? const Icon(Icons.edit_outlined) : null,
      onTap: onTap,
    );
  }

  void _openEditFieldSheet({
    required String title,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required Future<void> Function(String value) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: 'Masukkan $title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button.filled(
                    onPressed: () async {
                      final val = controller.text.trim();
                      if (val.isEmpty) return;
                      Navigator.pop(context);
                      await onSave(val);
                    },
                    label: 'Simpan',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
