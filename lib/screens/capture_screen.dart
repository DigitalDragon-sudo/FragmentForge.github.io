import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/fragment.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  String? _imagePath;
  String? _audioPath;
  final _textController = TextEditingController();
  final _moodController = TextEditingController();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((event) {
      if (!mounted) return; // ← This fixes the warning
      if ((event.x.abs() + event.y.abs() + event.z.abs()) > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fragment chaos detected... ready to capture?')),
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) setState(() => _imagePath = photo.path);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _audioPath = path;
        _isRecording = false;
      });
    } else {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/fragment_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _save() async {
    if (_textController.text.isEmpty &&
        _imagePath == null &&
        _audioPath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Capture something first')));
      return;
    }

    final box = Hive.box<Fragment>('fragments');
    final fragment = Fragment(
      imagePath: _imagePath,
      audioPath: _audioPath,
      text: _textController.text,
      timestamp: DateTime.now(),
      moodTag: _moodController.text.isEmpty ? 'Unknown' : _moodController.text,
    );

    await box.add(fragment);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fragment forged and stored')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Fragment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop Recording' : 'Record Voice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : null,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _toggleRecording,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Write your thoughts / feelings',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _moodController,
              decoration: const InputDecoration(
                labelText:
                    'Mood / Role tag (e.g. chaotic dreamer, angry artist)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: const Text(
                'Forge & Save Fragment',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _textController.dispose();
    _moodController.dispose();
    super.dispose();
  }
}
