// === FILE DIMULAI DARI SINI ===

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/core/assets/assets.gen.dart';
import 'package:flutter_absensi_app/core/components/spaces.dart';
import 'package:flutter_absensi_app/core/constants/colors.dart';
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/core/ml/recognition_embedding.dart';
import 'package:flutter_absensi_app/core/ml/recognizer.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/update_user_register_face/update_user_register_face_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/main_pages.dart';
import 'package:flutter_absensi_app/presentation/home/widget/face_detector_painter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as img;

class RegisterFaceAttendencePage extends StatelessWidget {
  const RegisterFaceAttendencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateUserRegisterFaceBloc(AuthRemoteDataSource()),
      child: const _RegisterFaceAttendencePageBody(),
    );
  }
}

class _RegisterFaceAttendencePageBody extends StatefulWidget {
  const _RegisterFaceAttendencePageBody({super.key});

  @override
  State<_RegisterFaceAttendencePageBody> createState() =>
      _RegisterFaceAttendencePageBodyState();
}

class _RegisterFaceAttendencePageBodyState
    extends State<_RegisterFaceAttendencePageBody> {
  List<CameraDescription>? _availableCameras;
  CameraDescription? description;
  CameraController? _controller;

  CameraLensDirection camDirec = CameraLensDirection.front;

  bool register = false;
  bool isBusy = false;
  bool cameraStopped = false;
  bool isUploading = false;

  late FaceDetector detector;
  late Recognizer recognizer;

  dynamic _scanResults;
  CameraImage? frame;
  img.Image? image;

  late List<RecognitionEmbedding> recognitions = [];

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
  }

  // ------------------------ CAMERA SETUP ------------------------

  Future<void> _initializeCamera() async {
    _availableCameras = await availableCameras();

    if (camDirec == CameraLensDirection.front) {
      description = _availableCameras!
          .firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    } else {
      description = _availableCameras!
          .firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    }

    _controller = CameraController(
      description!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _controller!.initialize();

    _controller!.startImageStream((CameraImage imageStream) async {
      if (isBusy || cameraStopped) return;

      isBusy = true;
      frame = imageStream;

      await doFaceDetectionOnFrame();

      // throttle
      await Future.delayed(const Duration(milliseconds: 35));

      isBusy = false;
    });

    if (mounted) setState(() {});
  }

  // ------------------------ MLKit Input ------------------------

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(frame!.width.toDouble(), frame!.height.toDouble());

    final rotation =
        InputImageRotationValue.fromRawValue(description!.sensorOrientation)!;

    const format = InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: frame!.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  // ------------------------ NV21 → RGB (SAMA DENGAN CHECKIN) ------------------------

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

    // 3-plane YUV_420_888
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

  // ------------------------ Face Detection ------------------------

  doFaceDetectionOnFrame() async {
    try {
      if (frame == null) {
        isBusy = false;
        return;
      }

      InputImage inputImage = getInputImage();
      List<Face> faces = await detector.processImage(inputImage);
      await performFaceRecognition(faces);
    } catch (_) {
      isBusy = false;
    }
  }

  // ------------------------ FACE RECOGNITION (SAMA CORE DENGAN CHECKIN) ------------------------

  Future<void> performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    if (frame == null) return;

    // Konversi NV21 → RGB
    image = _nv21ToImage(frame!);

    // ROTATE saja, jangan MIRROR
    image = img.copyRotate(
      image!,
      angle: camDirec == CameraLensDirection.front ? 270 : 90,
    );

    for (Face face in faces) {
      final bb = face.boundingBox;

      int x = bb.left.toInt().clamp(0, image!.width - 1);
      int y = bb.top.toInt().clamp(0, image!.height - 1);
      int w = bb.width.toInt().clamp(1, image!.width - x);
      int h = bb.height.toInt().clamp(1, image!.height - y);

      if (w <= 0 || h <= 0) continue;

      // Crop muka TEPAT sesuai MLKit
      final croppedFace = img.copyCrop(
        image!,
        x: x,
        y: y,
        width: w,
        height: h,
      );

      final rec = recognizer.recognize(croppedFace, face.boundingBox);
      recognitions.add(rec);

      if (register && faces.isNotEmpty && !cameraStopped) {
        register = false;
        cameraStopped = true;

        try {
          if (_controller!.value.isStreamingImages) {
            await _controller!.stopImageStream();
          }
        } catch (_) {}

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showFaceRegistrationDialogue(croppedFace, rec);
        });
      }
    }

    if (mounted) {
      setState(() {
        _scanResults = recognitions;
        isBusy = false;
      });
    }
  }


    // ------------------------ DIALOG ------------------------

  void showFaceRegistrationDialogue(
    img.Image croppedFace,
    RecognitionEmbedding recognition,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration", textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Image.memory(
                Uint8List.fromList(img.encodeBmp(croppedFace)),
                width: 200,
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocConsumer<UpdateUserRegisterFaceBloc,
                    UpdateUserRegisterFaceState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      orElse: () {},
                      error: (message) {
                        isUploading = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      success: (data) async {
                        isUploading = false;

                        final auth =
                            await AuthLocalDataSource().getAuthData();
                        AuthLocalDataSource().updateAuthData(data);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context.pushReplacement(const MainPage());
                        }
                      },
                    );
                  },
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      orElse: () {
                        return Button.filled(
                          onPressed: () async {
                            if (isUploading) return;
                            isUploading = true;

                            final jpgBytes = Uint8List.fromList(
                              img.encodeJpg(croppedFace, quality: 90),
                            );

                            context
                                .read<UpdateUserRegisterFaceBloc>()
                                .add(
                                  UpdateUserRegisterFaceEvent
                                      .updateProfileRegisterFace(
                                    recognition.embedding,
                                    jpgBytes,
                                  ),
                                );
                          },
                          label: 'Register',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ------------------------ CAMERA SWITCH ------------------------

  void _reverseCamera() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
    } else {
      camDirec = CameraLensDirection.back;
    }

    cameraStopped = false;
    isBusy = false;

    try {
      if (_controller != null &&
          _controller!.value.isInitialized &&
          _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller?.dispose();
    } catch (_) {}

    _initializeCamera();
  }

  // ------------------------ CAPTURE BUTTON ------------------------

  void _takePicture() {
    setState(() {
      register = true;
    });
  }

  // ------------------------ UI ------------------------

  Widget buildResult() {
    if (_scanResults == null ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const SizedBox();
    }

    final Size imageSize = Size(
      _controller!.value.previewSize!.height,
      _controller!.value.previewSize!.width,
    );

    CustomPainter painter =
        FaceDetectorPainter(imageSize, _scanResults, camDirec);

    return CustomPaint(painter: painter);
  }

  @override
  void dispose() {
    () async {
      try {
        if (_controller != null) {
          if (_controller!.value.isInitialized &&
              _controller!.value.isStreamingImages) {
            await _controller!.stopImageStream();
          }
          await _controller!.dispose();
        }
      } catch (_) {}
    }();

    detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              width: size.width,
              height: size.height,
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: buildResult(),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _reverseCamera,
                      icon: Assets.icons.reverse.svg(width: 48.0),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.circle, size: 70),
                      color: AppColors.red,
                    ),
                    const Spacer(),
                    const SpaceWidth(48.0),
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

// === END FILE ===
