import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../l10n/app_localizations.dart';

class CleanupScreen extends StatefulWidget {
  final String? title; // Добавляем настраиваемый заголовок/подсказку

  const CleanupScreen({
    super.key,
    this.title,
  });

  @override
  State<CleanupScreen> createState() => _CleanupScreenState();
}

class _CleanupScreenState extends State<CleanupScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  bool _restartCameraWhenReady = false;

  // Экземпляр детектора объектов от Google ML Kit
  late ObjectDetector _objectDetector;
  bool _isDetecting = false;
  String? _detectedInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    if (_isInitializingCamera || _controller != null) return;

    _isInitializingCamera = true;
    try {
      _cameras = await availableCameras();
      if (!mounted || _cameras == null || _cameras!.isEmpty) return;

      final controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
      );
      _controller = controller;

      await controller.initialize();
      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Ошибка инициализации камеры: $e');
      await _disposeCamera();
    } finally {
      _isInitializingCamera = false;
      if (_restartCameraWhenReady && mounted) {
        _restartCameraWhenReady = false;
        _initCamera();
      }
    }
  }

  Future<void> _disposeCamera() async {
    final controller = _controller;
    _controller = null;
    _isCameraInitialized = false;
    if (controller != null) {
      await controller.dispose();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _restartCameraWhenReady = false;
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_isInitializingCamera) {
        _restartCameraWhenReady = true;
      } else {
        _initCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _objectDetector.close();
    super.dispose();
  }

  Future<void> _takePictureAndDetect() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isDetecting) return;

    setState(() {
      _isDetecting = true;
      _detectedInfo = AppLocalizations.of(context).savingPhoto;
    });

    try {
      // 1. Делаем снимок
      final imageFile = await controller.takePicture();
      
      if (!mounted) return;

      // Release the camera before closing the route so Android has no pending requests.
      await _disposeCamera();
      if (!mounted) return;

      // 2. Возвращаем путь к файлу на предыдущий экран (ShelvesScreen)
      Navigator.pop(context, imageFile.path);

    } catch (e) {
      debugPrint('Ошибка при сохранении фото: $e');
      if (!mounted) return;
      setState(() {
        _isDetecting = false;
        _detectedInfo = AppLocalizations.of(context).captureError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.title ?? l10n.captureShelf;
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Используем переданный заголовок
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
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _detectedInfo ?? title,
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