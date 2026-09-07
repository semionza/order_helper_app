import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class CleanupScreen extends StatefulWidget {
  final String title; // Добавляем настраиваемый заголовок/подсказку

  const CleanupScreen({
    super.key, 
    this.title = 'Сделайте фото полки для анализа', // Дефолтное значение
  });

  @override
  State<CleanupScreen> createState() => _CleanupScreenState();
}

class _CleanupScreenState extends State<CleanupScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  // Экземпляр детектора объектов от Google ML Kit
  late ObjectDetector _objectDetector;
  bool _isDetecting = false;
  String _detectedInfo = 'Сделайте фото полки для анализа';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initObjectDetector();
  }

  void _initObjectDetector() {
    // Настраиваем базовую модель детекции объектов (с классификацией и поиском нескольких объектов)
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Ошибка инициализации камеры: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _objectDetector.close();
    super.dispose();
  }

Future<void> _takePictureAndDetect() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDetecting) return;

    setState(() {
      _isDetecting = true;
      _detectedInfo = 'Сохранение фото...';
    });

    try {
      // 1. Делаем снимок
      final imageFile = await _controller!.takePicture();
      
      if (!mounted) return;

      // 2. Возвращаем путь к файлу на предыдущий экран (ShelvesScreen)
      Navigator.pop(context, imageFile.path);

    } catch (e) {
      debugPrint('Ошибка при сохранении фото: $e');
      setState(() {
        _isDetecting = false;
        _detectedInfo = 'Ошибка при съемке';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Используем переданный заголовок
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Превью камеры на весь экран
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),
                // Информационная плашка сверху с результатами анализа
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _detectedInfo,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Кнопка съемки и анализа внизу
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _isDetecting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : FloatingActionButton.large(
                            onPressed: _takePictureAndDetect,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                          ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}