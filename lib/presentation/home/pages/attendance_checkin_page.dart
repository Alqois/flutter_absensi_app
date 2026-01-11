import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // untuk WriteBuffer
import 'package:flutter_absensi_app/core/assets/assets.gen.dart';
import 'package:flutter_absensi_app/core/components/spaces.dart';
import 'package:flutter_absensi_app/core/constants/colors.dart';
import 'package:flutter_absensi_app/core/ml/recognition_embedding.dart';
import 'package:flutter_absensi_app/core/ml/recognizer.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_success_page.dart';
import 'package:flutter_absensi_app/presentation/home/widget/face_detector_painter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';

class AttendanceCheckinPage extends StatefulWidget {
  const AttendanceCheckinPage({super.key});

  @override
  State<AttendanceCheckinPage> createState() => _AttendanceCheckinPageState();
}

class _AttendanceCheckinPageState extends State<AttendanceCheckinPage> {
  int lastProcessTime = 0;

  bool _isSwitchingCamera = false;
  bool _imageStreamStarted = false;
  bool cameraStopped = false;
  bool isBusy = false;

  List<CameraDescription>? _availableCameras;
  CameraDescription? _cameraDescription;
  CameraController? _controller;

  CameraLensDirection camDirec = CameraLensDirection.front;

  List<RecognitionEmbedding> recognitions = [];
  List<RecognitionEmbedding>? _scanResults;
  CameraImage? frame;
  img.Image? image;

  bool isFaceRegistered = false;
  String faceStatusMessage = "Wajah belum terdeteksi";

  late FaceDetector detector;
  late Recognizer recognizer;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    recognizer = Recognizer();

    _initializeCamera();
    getCurrentPosition();
  }

  @override
  void dispose() {
    cameraStopped = true;
    _isSwitchingCamera = true;
    _stopAndDisposeCamera();
    detector.close();
    super.dispose();
  }

  // =========================================================
  // CAMERA INIT / STOP
  // =========================================================

  Future<void> _stopAndDisposeCamera() async {
    try {
      if (_controller != null) {
        if (_imageStreamStarted &&
            _controller!.value.isInitialized &&
            _controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
          await Future.delayed(const Duration(milliseconds: 200));
        }
        _imageStreamStarted = false;

        await _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      debugPrint("Camera dispose error: $e");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _availableCameras ??= await availableCameras();

      _cameraDescription = _availableCameras!.firstWhere(
        (c) => c.lensDirection == camDirec,
        orElse: () => _availableCameras!.first,
      );

      _controller = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.nv21,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      cameraStopped = false;

      await _controller!.startImageStream((CameraImage imageStream) async {
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - lastProcessTime < 350) return; // throttle
        lastProcessTime = now;

        if (!mounted ||
            cameraStopped ||
            _isSwitchingCamera ||
            !(_controller?.value.isInitialized ?? false)) {
          return;
        }

        if (isBusy) return;

        isBusy = true;
        frame = imageStream;

        await doFaceDetectionOnFrame();

        isBusy = false;
      });

      _imageStreamStarted = true;

      setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  // =========================================================
  // FACE DETECTION + RECOGNITION
  // =========================================================

  Future<void> doFaceDetectionOnFrame() async {
    try {
      if (!mounted || frame == null || cameraStopped) return;

      final inputImage = _getInputImage();

      final faces = await detector.processImage(inputImage);

      if (faces.isEmpty) {
        if (!mounted) return;
        setState(() {
          _scanResults = [];
          isFaceRegistered = false;
          faceStatusMessage = "Wajah belum terdeteksi";
        });
        return;
      }

      await _performFaceRecognition(faces);
    } catch (e) {
      debugPrint("faceDetection error: $e");
    }
  }

  Future<void> _performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    if (frame == null) return;

    // Konversi NV21 -> RGB
    image = _nv21ToImage(frame!);

    // ROTATE sama seperti REGISTER (tanpa mirror)
    image = img.copyRotate(
      image!,
      angle: camDirec == CameraLensDirection.front ? 270 : 90,
    );

    bool found = false;
    String status = "Wajah belum terdeteksi";

    for (final face in faces) {
      final bb = face.boundingBox;

      if (bb.width < 30 || bb.height < 30) continue;

      int x = bb.left.toInt();
      int y = bb.top.toInt();
      int w = bb.width.toInt();
      int h = bb.height.toInt();

      // clamp supaya tidak keluar gambar
      x = x.clamp(0, image!.width - 1);
      y = y.clamp(0, image!.height - 1);
      w = w.clamp(1, image!.width - x);
      h = h.clamp(1, image!.height - y);

      if (w <= 0 || h <= 0) continue;

      final cropped = img.copyCrop(image!, x: x, y: y, width: w, height: h);

      final rec = recognizer.recognize(cropped, bb);
      recognitions.add(rec);

      final valid = await recognizer.isValidFace(rec.embedding);
      if (valid) {
        found = true;
        status = "Wajah sudah terdaftar";
      }
    }

    if (!mounted) return;

    setState(() {
      _scanResults = List<RecognitionEmbedding>.from(recognitions);
      isFaceRegistered = found;
      faceStatusMessage = status;
    });
  }

  // =========================================================
  // InputImage (rotation BY MLKit)
  // =========================================================

  InputImage _getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
        rotation: InputImageRotationValue.fromRawValue(
              _cameraDescription!.sensorOrientation,
            ) ??
            InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: frame!.planes[0].bytesPerRow,
      ),
    );
  }

  // =========================================================
  // NV21 → RGB (handle 1-plane & 3-plane)
  // =========================================================

  img.Image _nv21ToImage(CameraImage cameraImage) {
    final int w = cameraImage.width;
    final int h = cameraImage.height;

    final img.Image imgRGB = img.Image(width: w, height: h);

    // 1-plane NV21
    if (cameraImage.planes.length == 1) {
      final bytes = cameraImage.planes[0].bytes;
      final int frameSize = w * h;

      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final int yIndex = y * w + x;
          final int uvIndex = frameSize + (y >> 1) * w + (x & ~1);

          final int yValue = bytes[yIndex];
          final int vValue = bytes[uvIndex];
          final int uValue = bytes[uvIndex + 1];

          int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
          int g = (yValue -
                  0.344136 * (uValue - 128) -
                  0.714136 * (vValue - 128))
              .round()
              .clamp(0, 255);
          int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

          imgRGB.setPixelRgba(x, y, r, g, b, 255);
        }
      }

      return imgRGB;
    }

    // 3-plane (YUV_420_888)
    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final int yValue = yPlane.bytes[y * yRowStride + x];
        final int uvIndex =
            (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int uValue = uPlane.bytes[uvIndex];
        final int vValue = vPlane.bytes[uvIndex];

        int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
        int g = (yValue -
                0.344136 * (uValue - 128) -
                0.714136 * (vValue - 128))
            .round()
            .clamp(0, 255);
        int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

        imgRGB.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return imgRGB;
  }

  // =========================================================
  // LOCATION
  // =========================================================

  Future<void> getCurrentPosition() async {
    try {
      final location = Location();

      bool enabled = await location.serviceEnabled();
      if (!enabled) enabled = await location.requestService();

      PermissionStatus perm = await location.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await location.requestPermission();
      }

      final data = await location.getLocation();
      latitude = data.latitude;
      longitude = data.longitude;

      setState(() {});
    } catch (e) {}
  }

  // =========================================================
  // SWITCH CAMERA
  // =========================================================

  Future<void> _reverseCamera() async {
    if (_controller == null) return;

    _isSwitchingCamera = true;
    cameraStopped = true;
    isBusy = false;

    await _stopAndDisposeCamera();

    camDirec = camDirec == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    frame = null;
    _scanResults = [];

    await Future.delayed(const Duration(milliseconds: 150));

    await _initializeCamera();

    _isSwitchingCamera = false;
  }

  // =========================================================
  // CHECK-IN
  // =========================================================

  void _takeAbsen() {
    if (!isFaceRegistered) return;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi belum terbaca")),
      );
      return;
    }

    cameraStopped = true;

    context.read<CheckinAttendanceBloc>().add(
          CheckinAttendanceEvent.checkinAttendance(
            latitude.toString(),
            longitude.toString(),
          ),
        );
  }

  Future<void> safeStopCamera() async {
    await _stopAndDisposeCamera();
  }

  // =========================================================
  // Painter
  // =========================================================

  Widget buildResult() {
    if (_scanResults == null ||
        _controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.previewSize == null) {
      return Container();
    }

    return CustomPaint(
      painter: FaceDetectorPainter(
        Size(
          _controller!.value.previewSize!.height,
          _controller!.value.previewSize!.width,
        ),
        _scanResults!,
        camDirec,
      ),
    );
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_controller!),
            ),
            Positioned.fill(
              child: IgnorePointer(child: buildResult()),
            ),
            Positioned(
              top: 20,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFaceRegistered
                      ? AppColors.primary.withOpacity(0.47)
                      : AppColors.red.withOpacity(0.47),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  faceStatusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _reverseCamera,
                      icon: Assets.icons.reverse.svg(width: 48),
                    ),
                    const Spacer(),
                    BlocConsumer<CheckinAttendanceBloc,
                        CheckinAttendanceState>(
                      listener: (context, state) async {
                        state.maybeWhen(
                          loaded: (_) async {
                            await safeStopCamera();
                            if (!mounted) return;

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AttendanceSuccessPage(
                                  status: "Berhasil Checkin",
                                ),
                              ),
                            );
                          },
                          error: (msg) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          },
                          orElse: () {},
                        );
                      },
                      builder: (context, state) {
                        final onPressed = state.maybeWhen<VoidCallback?>(
                          loading: () => null,
                          orElse: () => (isFaceRegistered ? _takeAbsen : null),
                        );

                        final icon = state.maybeWhen<Widget>(
                          loading: () => const CircularProgressIndicator(),
                          orElse: () => const Icon(Icons.circle, size: 70),
                        );

                        return IconButton(
                          onPressed: onPressed,
                          icon: icon,
                          color:
                              isFaceRegistered ? AppColors.red : AppColors.grey,
                        );
                      },
                    ),
                    const Spacer(),
                    const SpaceWidth(48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
