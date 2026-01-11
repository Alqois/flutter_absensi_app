import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_absensi_app/core/ml/recognition_embedding.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  static const int WIDTH = 112;
  static const int HEIGHT = 112;

  String get modelName => 'assets/mobile_face_net.tflite';

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
      print("TFLite model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();
    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  // ----------------------------- NORMALIZED IMAGE ARRAY -----------------------------
  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resized =
        img.copyResize(inputImage, width: WIDTH, height: HEIGHT);

    Float32List input = Float32List(WIDTH * HEIGHT * 3);
    int index = 0;

    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        final px = resized.getPixel(x, y);

        final r = px.r;
        final g = px.g;
        final b = px.b;

        input[index++] = (r - 127.5) / 127.5;
        input[index++] = (g - 127.5) / 127.5;
        input[index++] = (b - 127.5) / 127.5;
      }
    }

    return input.reshape([1, 112, 112, 3]);
  }

  // ----------------------------- GET EMBEDDING -----------------------------
  RecognitionEmbedding recognize(img.Image image, Rect location) {
    final input = imageToArray(image);
    print(input.shape);

    List output = List.filled(192, 0).reshape([1, 192]);

    interpreter.run(input, output);

    List<double> emb = List<double>.from(output.first);
    print("embedding length = ${emb.length}");

    return RecognitionEmbedding(location, emb);
  }

  // ----------------------------- PARSE EMBEDDING FROM DB -----------------------------
  List<double> parseEmbedding(String raw) {
    try {
      final clean = raw.replaceAll('[', '').replaceAll(']', '');

      return clean
          .split(',')
          .map((e) => double.tryParse(e.trim()))
          .where((e) => e != null)
          .map((e) => e!)
          .toList();
    } catch (e) {
      print("Error parsing embedding from DB: $e");
      return [];
    }
  }

  // ----------------------------- COMPARE FACES -----------------------------
  PairEmbedding findNearest(List<double> emb, List<double> auth) {
    double distance = 0;

    for (int i = 0; i < emb.length; i++) {
      final diff = emb[i] - auth[i];
      distance += diff * diff;
    }

    return PairEmbedding(sqrt(distance));
  }

  // ----------------------------- MAIN CHECK VALID FACE -----------------------------
  Future<bool> isValidFace(List<double> emb) async {
    final authData = await AuthLocalDataSource().getAuthData();
    final dbEmbedding = authData!.user!.faceEmbedding;

    if (dbEmbedding == null || dbEmbedding.trim().isEmpty) {
      print("No saved embedding in database");
      return false;
    }

    final authFace = parseEmbedding(dbEmbedding);

    if (authFace.length != 192) {
      print("Invalid DB embedding length = ${authFace.length}");
      return false;
    }

    final pair = findNearest(emb, authFace);
    print("DISTANCE = ${pair.distance}");

    return pair.distance < 0.75;
  }
}

class PairEmbedding {
  double distance;
  PairEmbedding(this.distance);
}
