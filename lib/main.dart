import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdvancedMontajApp());
}

class AdvancedMontajApp extends StatelessWidget {
  const AdvancedMontajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'استوديو المونتاج الذكي PRO',
      locale: const Locale('ar'),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0E10),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF00FF66),
          surface: Color(0xFF1A1C1F),
          onSurface: Color(0xFFE2E4E9),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const StudioProPage(),
    );
  }
}

class AdvancedStylePreset {
  const AdvancedStylePreset({
    required this.id,
    required this.label,
    required this.contrast,
    required this.saturation,
    required this.gamma,
    required this.letterbox,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
  final double contrast;
  final double saturation;
  final double gamma;
  final bool letterbox;
}

// قائمة بـ 16 قالب سينمائي وحركي متنوع
const List<AdvancedStylePreset> advancedStyles = [
  AdvancedStylePreset(
    id: 'hollywood',
    label: '1. هوليوود السينمائي',
    contrast: 1.15,
    saturation: 0.85,
    gamma: 0.95,
    letterbox: true,
    description: 'ألوان باردة مع تباين سينمائي فاخر وصندوق أسود',
  ),
  AdvancedStylePreset(
    id: 'action_fast',
    label: '2. أكشن وسرعة خاطفة',
    contrast: 1.35,
    saturation: 1.30,
    gamma: 0.85,
    letterbox: false,
    description: 'تباين حاد وألوان بارزة تناسب التقطيع السريع والمشاهد الحركية',
  ),
  AdvancedStylePreset(
    id: 'teal_orange',
    label: '3. تيل آند أورنج سينمائي',
    contrast: 1.20,
    saturation: 1.25,
    gamma: 1.00,
    letterbox: false,
    description: 'عزل ألوان البشرة مع تلوين الخلفية بالأزرق الساحر',
  ),
  AdvancedStylePreset(
    id: 'cyberpunk',
    label: '4. نيون سايبر مستقبلي',
    contrast: 1.30,
    saturation: 1.50,
    gamma: 0.90,
    letterbox: false,
    description: 'ألوان نيون مشبعة جداً ملائمة لمقاطع الجيمنج والتحديات',
  ),
  AdvancedStylePreset(
    id: 'vintage_70s',
    label: '5. كلاسيك السبعينات',
    contrast: 0.90,
    saturation: 0.70,
    gamma: 1.10,
    letterbox: false,
    description: 'طابع الأفلام القديمة الدافئ والمحبب للعين',
  ),
  AdvancedStylePreset(
    id: 'documentary',
    label: '6. وثائقي واقعي',
    contrast: 1.02,
    saturation: 0.80,
    gamma: 1.00,
    letterbox: true,
    description: 'ألوان حقيقية ومريحة مأخوذة من كاميرات البث الاحترافية',
  ),
  AdvancedStylePreset(
    id: 'noir',
    label: '7. دراما أبيض وأسود',
    contrast: 1.35,
    saturation: 0.00,
    gamma: 0.85,
    letterbox: true,
    description: 'إضاءة درامية حادة وظلال عميقة بدون ألوان',
  ),
  AdvancedStylePreset(
    id: 'sunset_golden',
    label: '8. غروب ذهبي دافئ',
    contrast: 1.10,
    saturation: 1.30,
    gamma: 1.05,
    letterbox: false,
    description: 'درجات ألوان دافئة وساطعة توحي بأوقات الغروب الساحرة',
  ),
  AdvancedStylePreset(
    id: 'matrix_green',
    label: '9. ماتريكس سينما',
    contrast: 1.25,
    saturation: 1.10,
    gamma: 0.90,
    letterbox: false,
    description: 'طابع رقمي أخضر غامض مستوحى من عالم البرمجة والخيال',
  ),
  AdvancedStylePreset(
    id: 'vibrant_pop',
    label: '10. بوب آرت حركي',
    contrast: 1.40,
    saturation: 1.60,
    gamma: 1.00,
    letterbox: false,
    description: 'ألوان قوية وحيوية تلفت الانتباه فوراً في السوشيال ميديا',
  ),
  AdvancedStylePreset(
    id: 'cold_thriller',
    label: '11. إثارة وغموض بارد',
    contrast: 1.25,
    saturation: 0.60,
    gamma: 0.90,
    letterbox: true,
    description: 'درجات ألوان ثلجية وزرقاء تعطي شعور الغموض والتشويق',
  ),
  AdvancedStylePreset(
    id: 'autumn_vibes',
    label: '12. خريف دافئ',
    contrast: 1.15,
    saturation: 1.10,
    gamma: 1.05,
    letterbox: false,
    description: 'درجات البرتقالي والبني مع لمسة سينمائية هادئة',
  ),
  AdvancedStylePreset(
    id: 'retro_vhs',
    label: '13. فيديو كاسيت ريترو',
    contrast: 1.05,
    saturation: 0.85,
    gamma: 1.15,
    letterbox: false,
    description: 'طابع التسعينات الثمانيناتي الدافئ مع ظلال ناعمة',
  ),
  AdvancedStylePreset(
    id: 'high_contrast_bw',
    label: '14. أبيض وأسود عالي التباين',
    contrast: 1.50,
    saturation: 0.00,
    gamma: 0.80,
    letterbox: false,
    description: 'تباين حاد جداً ينفع للمشاهد الحركية السريعة والرياضة',
  ),
  AdvancedStylePreset(
    id: 'soft_dreamy',
    label: '15. حالم وناعم السينمائي',
    contrast: 0.85,
    saturation: 0.90,
    gamma: 1.20,
    letterbox: true,
    description: 'إضاءة خفيفة وناعمة تناسب المشاهد الفنية والهادئة',
  ),
  AdvancedStylePreset(
    id: 'urban_street',
    label: '16. ستريت ستايل عصري',
    contrast: 1.30,
    saturation: 1.15,
    gamma: 0.95,
    letterbox: false,
    description: 'تباين قوي وألوان متناسقة تناسب فلوجات الشارع والموضة',
  ),
];

class ShotItem {
  ShotItem({required this.path, required this.isImage, required this.name});
  final String path;
  final String name;
  final bool isImage;
}

class StudioProPage extends StatefulWidget {
  const StudioProPage({super.key});

  @override
  State<StudioProPage> createState() => _StudioProPageState();
}

class _StudioProPageState extends State<StudioProPage> {
  final ImagePicker _picker = ImagePicker();
  final List<ShotItem> _shots = [];
  final TextEditingController _textOverlayController = TextEditingController();

  int _selectedStyle = 0;
  int _selectedAspect = 0;
  int _currentPlayingIndex = 0;
  int _durationIndex = 2;

  bool _isPlayingPreview = false;
  bool _isGeneratingVideo = false;
  bool _isTextOverlayEnabled = false;
  String? _lastGeneratedVideoPath;

  double _previewProgress = 0.0;
  String _generationStatus = '';

  VideoPlayerController? _videoController;
  Timer? _playbackTimer;
  Timer? _progressUpdateTimer;

  static const List<(String, int, int)> aspectRatios = [
    ('ريلز وتيك توك (9:16)', 720, 1280),
    ('يوتيوب عريض (16:9)', 1280, 720),
    ('انستقرام مربع (1:1)', 1080, 1080),
  ];

  static const List<(String, double)> targetDurations = [
    ('٥ ثوانٍ', 5.0),
    ('١٠ ثوانٍ', 10.0),
    ('٣٠ ثانية', 30.0),
    ('٦٠ ثانية (دقيقة)', 60.0),
  ];

  AdvancedStylePreset get currentStyle => advancedStyles[_selectedStyle];
  double get totalTargetDuration => targetDurations[_durationIndex].$2;
  double get singleShotDuration => _shots.isEmpty ? 1.0 : (totalTargetDuration / _shots.length);

  @override
  void dispose() {
    _clearTimers();
    _videoController?.dispose();
    _textOverlayController.dispose();
    super.dispose();
  }

  void _clearTimers() {
    _playbackTimer?.cancel();
    _progressUpdateTimer?.cancel();
  }

  Future<void> _addMedia({required bool isImage}) async {
    if (_shots.length >= 12) {
      _showSnackBar('الحد الأقصى ١٢ لقطة للمشروع');
      return;
    }
    try {
      final List<XFile> pickedFiles = isImage 
          ? await _picker.pickMultiImage() 
          : await _picker.pickMultiVideo();
          
      if (pickedFiles.isEmpty) return;

      for (final XFile file in pickedFiles.take(12 - _shots.length)) {
        if (!mounted) return;
        setState(() {
          _shots.add(ShotItem(path: file.path, isImage: isImage, name: file.name));
        });
      }
    } catch (_) {
      _showSnackBar('يرجى تفعيل صلاحية الوصول لمعرض الوسائط');
    }
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _stopPreview() async {
    _clearTimers();
    final VideoPlayerController? controller = _videoController;
    _videoController = null;
    await controller?.pause();
    await controller?.dispose();
    if (mounted) {
      setState(() {
        _isPlayingPreview = false;
        _previewProgress = 0.0;
      });
    }
  }

  Future<void> _startPreview() async {
    if (_shots.isEmpty) return;
    await _stopPreview();
    if (!mounted) return;
    setState(() {
      _isPlayingPreview = true;
      _currentPlayingIndex = 0;
    });
    await _loadCurrentPreviewShot();
  }

  Future<void> _loadCurrentPreviewShot() async {
    if (!_isPlayingPreview || _shots.isEmpty) return;
    final ShotItem currentShot = _shots[_currentPlayingIndex];
    double currentHoldTime = singleShotDuration;

    if (!currentShot.isImage) {
      _videoController = VideoPlayerController.file(File(currentShot.path));
      try {
        await _videoController!.initialize();
        if (!mounted || !_isPlayingPreview) {
          await _videoController!.dispose();
          return;
        }
        final double actualDuration = _videoController!.value.duration.inMilliseconds / 1000;
        if (actualDuration > 0 && actualDuration < currentHoldTime) {
          currentHoldTime = actualDuration;
        }
        await _videoController!.play();
        setState(() {});
      } catch (_) {
        _showSnackBar('تعذر معاينة ملف الفيديو: ${currentShot.name}');
      }
    } else {
      if (mounted) setState(() {});
    }

    _startProgressTimer(currentHoldTime);

    _playbackTimer = Timer(Duration(milliseconds: (currentHoldTime * 1000).round()), () async {
      _progressUpdateTimer?.cancel();
      if (!_isPlayingPreview) return;

      if (_videoController != null) {
        await _videoController!.pause();
        await _videoController!.dispose();
        _videoController = null;
      }

      if (_currentPlayingIndex >= _shots.length - 1) {
        if (mounted) {
          setState(() {
            _isPlayingPreview = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _currentPlayingIndex += 1;
          _previewProgress = 0.0;
        });
        await _loadCurrentPreviewShot();
      }
    });
  }

  void _startProgressTimer(double duration) {
    _progressUpdateTimer?.cancel();
    final DateTime startTime = DateTime.now();
    _progressUpdateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final double elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000;
      if (mounted) {
        setState(() {
          _previewProgress = (elapsed / duration).clamp(0.0, 1.0);
        });
      }
    });
  }

  // دالة لجلب مدة الفيديو بالثواني
  Future<double> _getVideoDuration(String videoPath) async {
    try {
      final mediaInformationSession = await FFprobeKit.getMediaInformation(videoPath);
      final mediaInformation = mediaInformationSession.getMediaInformation();
      final durationStr = mediaInformation?.getDuration();
      if (durationStr != null) {
        return double.tryParse(durationStr) ?? 0.0;
      }
    } catch (_) {}
    return 0.0;
  }

  Future<void> _generateFinalVideo() async {
    if (_shots.isEmpty || _isGeneratingVideo) return;
    setState(() {
      _isGeneratingVideo = true;
      _generationStatus = 'الذكاء الاصطناعي يختار التقطيعات العشوائية ويطبق القالب السينمائي...';
    });
    await _stopPreview();

    try {
      final Directory appDir = await getTemporaryDirectory();
      final (String, int, int) targetSize = aspectRatios[_selectedAspect];
      final int width = targetSize.$2;
      final int height = targetSize.$3;
      final String outputVideoPath = '${appDir.path}/render_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final List<String> ffmpegArguments = [];
      final double shotDuration = singleShotDuration;
      final Random random = Random();

      for (final ShotItem shot in _shots) {
        if (shot.isImage) {
          ffmpegArguments.addAll(['-loop', '1', '-t', '$shotDuration', '-i', shot.path]);
        } else {
          // حساب مدة الفيديو الكلية واختيار نقطة بداية عشوائية (Random Cut)
          double videoDuration = await _getVideoDuration(shot.path);
          double startTime = 0.0;
          if (videoDuration > shotDuration) {
            double maxStart = videoDuration - shotDuration;
            startTime = random.nextDouble() * maxStart; // بداية عشوائية
          }
          ffmpegArguments.addAll([
            '-ss', startTime.toStringAsFixed(2),
            '-t', '$shotDuration',
            '-i', shot.path
          ]);
        }
      }

      String filterGraph = '';
      for (int i = 0; i < _shots.length; i++) {
        // توحيد الأبعاد وصيغة الألوان والإطارات لتجنب أي فشل في التوليد
        filterGraph += '[$i:v]scale=$width:$height:force_original_aspect_ratio=decrease,pad=$width:$height:(ow-iw)/2:(oh-ih)/2,setsar=1,format=yuv420p,fps=30';
        filterGraph += ',eq=contrast=${currentStyle.contrast}:saturation=${currentStyle.saturation}:gamma=${currentStyle.gamma}';
        if (currentStyle.letterbox) {
          filterGraph += ',drawbox=y=0:h=$height/10:color=black:t=fill,drawbox=y=h-h/10:h=$height/10:color=black:t=fill';
        }
        filterGraph += '[v$i];';
      }

      String concatFilter = '';
      for (int i = 0; i < _shots.length; i++) {
        concatFilter += '[v$i]';
      }
      concatFilter += 'concat=n=${_shots.length}:v=1:a=0[concv];';
      filterGraph += concatFilter;

      // تطبيق الكتابة على الفيديو إن وجدت
      if (_isTextOverlayEnabled && _textOverlayController.text.trim().isNotEmpty) {
        final String textContent = _textOverlayController.text.trim().replaceAll("'", "\\'");
        filterGraph += '[concv]drawtext=text=\'$textContent\':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-140:box=1:boxcolor=black@0.6:boxborderw=8[outv]';
      } else {
        filterGraph += '[concv]copy[outv]';
      }

      ffmpegArguments.addAll([
        '-filter_complex', filterGraph,
        '-map', '[outv]',
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-pix_fmt', 'yuv420p',
        '-y', outputVideoPath,
      ]);

      setState(() => _generationStatus = 'محرك المعالجة يدمج اللقطات العشوائية بأقصى سرعة عتادية...');

      final session = await FFmpegKit.executeWithArguments(ffmpegArguments);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _lastGeneratedVideoPath = outputVideoPath;
        _showSnackBar('تم إنتاج الفيديو بنجاح! يمكنك الآن حفظه وتصديره.');
      } else {
        final failLog = await session.getFailStackTrace();
        debugPrint('FFmpeg Error Log: $failLog');
        _showSnackBar('فشلت عملية رندرة وتوليد الفيديو النهائي');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showSnackBar('حدث خطأ غير متوقع أثناء المعالجة');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingVideo = false;
          _generationStatus = '';
        });
      }
    }
  }

  Future<void> _exportAndSaveVideo() async {
    if (_lastGeneratedVideoPath == null || !File(_lastGeneratedVideoPath!).existsSync()) {
      _showSnackBar('يرجى توليد الفيديو أولاً بالنقر على "توليد وإنتاج ذكي"');
      return;
    }

    try {
      final Directory externalDir = Directory('/storage/emulated/0/Download');
      if (await externalDir.exists()) {
        final String savedPath = '${externalDir.path}/MontajPro_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await File(_lastGeneratedVideoPath!).copy(savedPath);
        _showSnackBar('تم حفظ الفيديو في مجلد التنزيلات (Downloads)!');
      }
      await Share.shareXFiles([XFile(_lastGeneratedVideoPath!)], text: 'فيديو احترافي صُمم عبر استوديو المونتاج الذكي');
    } catch (_) {
      await Share.shareXFiles([XFile(_lastGeneratedVideoPath!)], text: 'فيديو احترافي صُمم عبر استوديو المونتاج الذكي');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'استوديو المونتاج الذكي PRO',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF141619),
        elevation: 0,
      ),
      body: _isGeneratingVideo
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF00FF66), strokeWidth: 5),
                    const SizedBox(height: 24),
                    Text(
                      _generationStatus,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'يتم استخدام خوارزميات التقطيع العشوائي والمعالجة السريعة',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141619),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Center(
                          child: _shots.isEmpty
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.psychology_outlined, size: 48, color: Color(0xFF00FF66)),
                                    SizedBox(height: 12),
                                    Text(
                                      'محرك التقطيع العشوائي جاهز، أضف لقطات للبدء',
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                )
                              : (_shots[_currentPlayingIndex].isImage
                                  ? Image.file(File(_shots[_currentPlayingIndex].path), fit: BoxFit.contain)
                                  : (_videoController != null && _videoController!.value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio: _videoController!.value.aspectRatio,
                                          child: VideoPlayer(_videoController!),
                                        )
                                      : const CircularProgressIndicator(color: Colors.white))),
                        ),
                        if (_isPlayingPreview)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              value: _previewProgress,
                              backgroundColor: Colors.white10,
                              color: Colors.amber,
                              minHeight: 4,
                            ),
                          ),
                        if (_shots.isNotEmpty)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'اللقطة: ${_currentPlayingIndex + 1}/${_shots.length}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1C1F),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: const Text('أضف صور'),
                          onPressed: () => _addMedia(isImage: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1C1F),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.video_collection_outlined, size: 18),
                          label: const Text('أضف فيديو'),
                          onPressed: () => _addMedia(isImage: false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF141619),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.av_timer, size: 18, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text('مؤقت مدة الفيديو الإجمالية:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              DropdownButton<int>(
                                value: _durationIndex,
                                underline: const SizedBox(),
                                dropdownColor: const Color(0xFF1A1C1F),
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                                items: List.generate(
                                  targetDurations.length,
                                  (i) => DropdownMenuItem(value: i, child: Text(targetDurations[i].$1)),
                                ),
                                onChanged: (val) {
                                  if (val != null) setState(() => _durationIndex = val);
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 18, color: Colors.cyan),
                                  SizedBox(width: 8),
                                  Text('قالب التلوين السينمائي (16 قالب):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              DropdownButton<int>(
                                value: _selectedStyle,
                                underline: const SizedBox(),
                                dropdownColor: const Color(0xFF1A1C1F),
                                style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 13),
                                items: List.generate(
                                  advancedStyles.length,
                                  (i) => DropdownMenuItem(value: i, child: Text(advancedStyles[i].label)),
                                ),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedStyle = val);
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              currentStyle.description,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.aspect_ratio, size: 18, color: Colors.purpleAccent),
                                  SizedBox(width: 8),
                                  Text('أبعاد ومقاس شاشة الإخراج:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              DropdownButton<int>(
                                value: _selectedAspect,
                                underline: const SizedBox(),
                                dropdownColor: const Color(0xFF1A1C1F),
                                style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                items: List.generate(
                                  aspectRatios.length,
                                  (i) => DropdownMenuItem(value: i, child: Text(aspectRatios[i].$1)),
                                ),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedAspect = val);
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.text_fields, size: 18, color: Colors.greenAccent),
                                  SizedBox(width: 8),
                                  Text('الكتابة على الفيديو (نص ثابت):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Switch(
                                value: _isTextOverlayEnabled,
                                activeColor: const Color(0xFF00FF66),
                                onChanged: (val) {
                                  setState(() => _isTextOverlayEnabled = val);
                                },
                              ),
                            ],
                          ),
                          if (_isTextOverlayEnabled) ...[
                            const SizedBox(height: 6),
                            TextField(
                              controller: _textOverlayController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'اكتب النص الذي سيظهر أسفل الفيديو...',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF1A1C1F),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: Colors.white24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: Icon(
                                    _isPlayingPreview ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _isPlayingPreview ? 'إيقاف المعاينة' : 'تشغيل المعاينة',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _shots.isEmpty || _isGeneratingVideo
                                      ? null
                                      : (_isPlayingPreview ? _stopPreview : _startPreview),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: const Color(0xFF00FF66),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 4,
                                  ),
                                  icon: const Icon(Icons.bolt),
                                  label: const Text(
                                    'توليد وإنتاج ذكي',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  onPressed: _shots.isEmpty || _isGeneratingVideo ? null : _generateFinalVideo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.download_for_offline_outlined),
                              label: const Text(
                                'حفظ وتصدير الفيديو للجهاز',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: _lastGeneratedVideoPath == null || _isGeneratingVideo ? null : _exportAndSaveVideo,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}