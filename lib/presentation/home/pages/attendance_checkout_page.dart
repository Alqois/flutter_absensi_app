import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/core/ml/recognition_embedding.dart';
import 'package:flutter_absensi_app/core/ml/recognizer.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_success_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/location_page.dart';
import 'package:flutter_absensi_app/presentation/home/widget/face_detector_painter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';
import '../../../core/core.dart';

class AttendanceCheckoutPage extends StatefulWidget {
  const AttendanceCheckoutPage({super.key});

  @override
  State<AttendanceCheckoutPage> createState() => _AttendanceCheckoutPageState();
}

class _AttendanceCheckoutPageState extends State<AttendanceCheckoutPage> {
  bool _isSwitchingCamera = false;
  bool _imageStreamStarted = false;
  bool isBusy = false;
  bool cameraStopped = false;

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

  // ===================================================================
  // CAMERA INIT / STOP
  // ===================================================================

  Future<void> _stopAndDisposeCamera() async {
    try {
      if (_controller != null) {
        if (_imageStreamStarted &&
            _controller!.value.isInitialized &&
            _controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
          // beri jeda biar CameraX beresin buffer internal
          await Future.delayed(const Duration(milliseconds: 200));
        }
        _imageStreamStarted = false;

        await _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      debugPrint("Dispose camera error: $e");
    }
  }
  
  Future<void> safeStopCamera() async {
    await _stopAndDisposeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _availableCameras ??= await availableCameras();

      if (_availableCameras == null || _availableCameras!.isEmpty) {
        debugPrint("No cameras found");
        return;
      }

      _cameraDescription = _availableCameras!.firstWhere(
        (c) => c.lensDirection == camDirec,
        orElse: () => _availableCameras!.first,
      );

      _controller = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,          // disamain dengan register & checkin
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();
      if (!mounted) return;

      cameraStopped = false;
      _imageStreamStarted = false;

      await _controller!.startImageStream((CameraImage imageStream) async {
        if (!mounted ||
            cameraStopped ||
            _isSwitchingCamera ||
            _controller == null ||
            !_controller!.value.isInitialized) return;

        if (isBusy) return;
        isBusy = true;

        frame = imageStream;
        await doFaceDetectionOnFrame();

        await Future.delayed(const Duration(milliseconds: 35));
        isBusy = false;
      });

      _imageStreamStarted = true;
      setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  // ===================================================================
  // FACE DETECTION
  // ===================================================================

  Future<void> doFaceDetectionOnFrame() async {
    try {
      if (frame == null || cameraStopped) return;

      final input = getInputImage();
      List<Face> faces = await detector.processImage(input);

      if (faces.isEmpty) {
        if (!mounted) return;
        setState(() {
          isFaceRegistered = false;
          faceStatusMessage = "Wajah tidak terdeteksi";
          _scanResults = [];
        });
        return;
      }

      await performFaceRecognition(faces);
    } catch (e) {
      debugPrint("Face detect error: $e");
    }
  }

  Future<void> performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    if (frame == null) return;

    // 🔹 NV21 → RGB (sama dengan REGISTER & CHECKIN)
    image = _nv21ToImage(frame!);

    // 🔹 ROTATE saja, TANPA mirror (biar sama semua)
    image = img.copyRotate(
      image!,
      angle: camDirec == CameraLensDirection.front ? 270 : 90,
    );

    bool valid = false;

    for (Face face in faces) {
      final bb = face.boundingBox;

      // skip muka terlalu kecil
      if (bb.width < 30 || bb.height < 30) continue;

      int x = bb.left.toInt();
      int y = bb.top.toInt();
      int w = bb.width.toInt();
      int h = bb.height.toInt();

      // clamp supaya bounding box tetap di dalam gambar
      x = x.clamp(0, image!.width - 1);
      y = y.clamp(0, image!.height - 1);
      w = w.clamp(1, image!.width - x);
      h = h.clamp(1, image!.height - y);

      if (w <= 0 || h <= 0) continue;

      // 🔹 Crop muka TEPAT sesuai bounding box MLKit
      final crop = img.copyCrop(image!, x: x, y: y, width: w, height: h);

      final rec = recognizer.recognize(crop, bb);
      recognitions.add(rec);

      bool isValid = await recognizer.isValidFace(rec.embedding);
      if (isValid) valid = true;
    }

    if (!mounted) return;

    setState(() {
      _scanResults = recognitions;
      isFaceRegistered = valid;
      faceStatusMessage =
          valid ? "Wajah sudah terdaftar" : "Wajah belum terdaftar";
    });
  }

  // ===================================================================
  // NV21 → RGB (handle 3-plane; 1-plane bisa ditambah kalau perlu)
  // ===================================================================

  img.Image _nv21ToImage(CameraImage cameraImage) {
    final int w = cameraImage.width;
    final int h = cameraImage.height;

    final img.Image imgRGB = img.Image(width: w, height: h);

    // Kalau device kirim 1-plane NV21, diadaptasi seperti di REGISTER
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

    // Default: 3-plane YUV_420_888
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

  // ===================================================================
  // INPUT IMAGE UNTUK MLKIT
  // ===================================================================

  InputImage getInputImage() {
    final WriteBuffer buffer = WriteBuffer();
    for (final plane in frame!.planes) {
      buffer.putUint8List(plane.bytes);
    }
    final bytes = buffer.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
        rotation: InputImageRotationValue.fromRawValue(
              _cameraDescription!.sensorOrientation,
            ) ??
            InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: frame!.planes.first.bytesPerRow,
      ),
    );
  }

  // ===================================================================
  // SWITCH CAMERA
  // ===================================================================

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

    await _initializeCamera();

    _isSwitchingCamera = false;
  }

  // ===================================================================
  // LOCATION
  // ===================================================================

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool enabled = await location.serviceEnabled();
      if (!enabled) enabled = await location.requestService();
      if (!enabled) return;

      PermissionStatus perm = await location.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await location.requestPermission();
        if (perm != PermissionStatus.granted) return;
      }

      final data = await location.getLocation();
      latitude = data.latitude;
      longitude = data.longitude;

      setState(() {});
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ===================================================================
  // TAKE ABSEN
  // ===================================================================

  void _takeAbsen() {
    if (!isFaceRegistered) return;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi belum terbaca")),
      );
      return;
    }

    cameraStopped = true;

    context.read<CheckoutAttendanceBloc>().add(
          CheckoutAttendanceEvent.checkoutAttendance(
            latitude.toString(),
            longitude.toString(),
          ),
        );
  }


  // ===================================================================
  // UI
  // ===================================================================

  Widget buildResult() {
    if (_scanResults == null ||
        _controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.previewSize == null) {
      return const SizedBox();
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

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
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
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _reverseCamera,
                          icon: Assets.icons.reverse.svg(width: 48),
                        ),
                        const Spacer(),
                        BlocConsumer<CheckoutAttendanceBloc,
                            CheckoutAttendanceState>(
                          listener: (context, state) {
                            state.maybeWhen(
                              loaded: (_) async {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendanceSuccessPage(
                                      status: "Berhasil Checkout",
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
                            return state.maybeWhen(
                              loading: () => const CircularProgressIndicator(),
                              orElse: () {
                                return IconButton(
                                  onPressed:
                                      isFaceRegistered ? _takeAbsen : null,
                                  icon: const Icon(Icons.circle, size: 70),
                                  color: isFaceRegistered
                                      ? Colors.red
                                      : Colors.grey,
                                );
                              },
                            );
                          },
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
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
