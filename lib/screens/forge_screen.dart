import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import '../models/fragment.dart';

const String _groqApiKey = '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';
const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

class ForgeScreen extends StatefulWidget {
  const ForgeScreen({super.key});

  @override
  State<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends State<ForgeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, String> _aiDescriptions = {};
  final Map<int, bool> _loadingStates = {};

  Future<void> _aiRemix(int index, Fragment frag) async {
    setState(() => _loadingStates[index] = true);

    // Build a unique prompt from this specific fragment's data
    final mood = frag.moodTag != 'Unknown' ? frag.moodTag : 'undefined';
    final text = frag.text.isNotEmpty ? frag.text : 'no words, just feeling';
    final time = frag.timestamp.toString().substring(0, 16);
    final hasImage = frag.imagePath != null ? 'yes' : 'no';
    final hasVoice = frag.audioPath != null ? 'yes' : 'no';

    final prompt = '''
You are a surreal poet for an app called FragmentForge where teens capture raw emotional moments.

Take this specific emotional fragment and rewrite it as a unique, poetic, artistic interpretation.
Every remix must feel completely different — never use the same structure or metaphors twice.

Fragment details:
- Mood tag: $mood
- What they wrote: "$text"
- Captured at: $time
- Has photo: $hasImage
- Has voice recording: $hasVoice

Write 2-3 sentences of surreal, vivid poetry that is specific to THIS fragment.
Make it feel like art, not therapy. Be unexpected and emotionally alive.
''';

    try {
      final response = await http.post(
        Uri.parse(_groqEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'max_tokens': 200,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        setState(() {
          _aiDescriptions[index] = reply.trim();
          _loadingStates[index] = false;
        });
      } else {
        setState(() {
          _aiDescriptions[index] = 'The signal got lost. Tap again to retry.';
          _loadingStates[index] = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiDescriptions[index] = 'Could not reach the forge. Try again.';
        _loadingStates[index] = false;
      });
    }
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
              final isLoading = _loadingStates[index] ?? false;

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

                      // ── AI Remix Button ──────────────────
                      ElevatedButton.icon(
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(isLoading ? 'Remixing...' : 'AI Remix'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed:
                            isLoading ? null : () => _aiRemix(index, frag),
                      ),

                      // ── AI Remix Result ──────────────────
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