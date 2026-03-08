import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/fragment.dart';

class ForgeScreen extends StatefulWidget {
  const ForgeScreen({super.key});

  @override
  State<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends State<ForgeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, String> _aiDescriptions = {};

  String _generateAIRemixDescription(Fragment frag) {
    String base = frag.text.isNotEmpty
        ? frag.text
        : (frag.moodTag != 'Unknown' ? frag.moodTag : 'a silent moment');
    String mood =
        frag.moodTag != 'Unknown' ? frag.moodTag.toLowerCase() : 'raw';
    return "In the fractured neon of midnight, $base folds into itself — $mood shards reflecting a thousand unfinished versions of you. The edges bleed static, whispering: you are not one story, you are the collision.";
  }

  void _aiRemix(int index, Fragment frag) {
    setState(() {
      _aiDescriptions[index] = _generateAIRemixDescription(frag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Forge')),
      body: ValueListenableBuilder<Box<Fragment>>(
        valueListenable: Hive.box<Fragment>('fragments').listenable(),
        builder: (context, box, _) {
          final fragments = box.values.toList();

          if (fragments.isEmpty) {
            return const Center(child: Text('No fragments forged yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fragments.length,
            itemBuilder: (context, index) {
              final frag = fragments[index];
              final aiText = _aiDescriptions[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        frag.moodTag,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        frag.timestamp.toString().substring(0, 16),
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 12),
                      if (frag.text.isNotEmpty) ...[
                        Text(frag.text),
                        const SizedBox(height: 12),
                      ],
                      if (frag.imagePath != null) ...[
                        GestureDetector(
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(frag.imagePath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (frag.audioPath != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play Voice'),
                          onPressed: () async {
                            try {
                              await _audioPlayer.play(
                                DeviceFileSource(frag.audioPath!),
                              );
                            } catch (_) {}
                          },
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI Remix'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: () => _aiRemix(index, frag),
                      ),
                      if (aiText != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.deepPurpleAccent
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            aiText,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.purple[100],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
