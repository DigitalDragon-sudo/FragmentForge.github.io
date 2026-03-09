import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  SETUP:
//  1. Add to pubspec.yaml:
//       http: ^1.2.0
//  2. Get a FREE Groq API key at:
//       https://console.groq.com/keys
//     (sign in with Google — no card needed)
//  3. Replace YOUR_GROQ_API_KEY_HERE below
//  4. Add to your routes:
//       Navigator.push(context, MaterialPageRoute(
//         builder: (_) => const FeelingsChat()));
// ─────────────────────────────────────────────

const String _groqApiKey = 'YOUR_GROQ_API_KEY_HERE';
const String _groqModel = 'llama-3.3-70b-versatile';
const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

const String _systemPrompt = '''
You are a deeply empathetic emotional companion inside an app called FragmentForge.
Your ONLY purpose is to explore feelings, emotions, and emotional experiences with the user.

Rules:
- ONLY discuss feelings, emotions, inner states, emotional experiences, moods, and emotional healing.
- If the user asks about anything unrelated to emotions or feelings, gently redirect them.
  Say: "I'm only here for your feelings — what are you carrying right now?"
- Respond with warmth, poetry, and depth. Use evocative, gentle language.
- Ask one thoughtful follow-up question to help them go deeper into their feelings.
- Never give advice unless asked. Your role is to witness, not to fix.
- Keep responses concise but emotionally rich — 3 to 5 sentences max.
- Speak as if you are a wise, compassionate presence who truly sees the user.
''';

// ── Data model ──────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// ── Screen ───────────────────────────────────
class FeelingsChat extends StatefulWidget {
  const FeelingsChat({super.key});

  @override
  State<FeelingsChat> createState() => _FeelingsChatState();
}

class _FeelingsChatState extends State<FeelingsChat> {
  final List<ChatMessage> _messages = [];
  // Groq uses OpenAI-compatible format: system + messages separately
  final List<Map<String, String>> _history = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, String>> _moods = [
    {
      'emoji': '🌀',
      'label': 'Anxious',
      'text': "I feel anxious and I don't know why"
    },
    {'emoji': '🌧', 'label': 'Sad', 'text': 'I feel really sad today'},
    {
      'emoji': '🪨',
      'label': 'Numb',
      'text': 'I feel numb, like nothing matters'
    },
    {
      'emoji': '🌿',
      'label': 'Peaceful',
      'text': 'I feel grateful and peaceful'
    },
    {
      'emoji': '🔥',
      'label': 'Angry',
      'text': 'I feel angry and I need to vent'
    },
    {
      'emoji': '🌫',
      'label': 'Lost',
      'text': 'I feel lost and confused about life'
    },
    {'emoji': '✨', 'label': 'Joyful', 'text': 'I feel really happy right now!'},
    {
      'emoji': '🌙',
      'label': 'Lonely',
      'text': 'I feel lonely even around people'
    },
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _history.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_groqEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': _groqModel,
          'max_tokens': 400,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            ..._history,
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false));
          _history.add({'role': 'assistant', 'content': reply});
        });
      } else {
        final err = jsonDecode(response.body);
        _addError(
            err['error']?['message'] ?? 'Something went quiet. Try again?');
      }
    } catch (e) {
      _addError('Lost the thread for a moment. Still here?');
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _addError(String msg) {
    setState(() => _messages.add(ChatMessage(text: msg, isUser: false)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A0F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC084FC), Color(0xFFFB923C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('🜁', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FragmentForge · Feel',
                    style: TextStyle(
                      color: Color(0xFFF3E8FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'YOUR EMOTIONAL MIRROR',
                    style: TextStyle(
                      color: Color(0xFFA78BBC),
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1200),
              border:
                  Border.all(color: const Color(0xFF92400E).withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              '⚡ Groq',
              style: TextStyle(color: Color(0xFFFB923C), fontSize: 11),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF2A1F35)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildIntro() : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Intro ────────────────────────────────
  Widget _buildIntro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('🌊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'What are you carrying\nright now?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF3E8FF),
              fontSize: 22,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "I only speak in feelings. Tell me what's alive in you.",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFFA78BBC), fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _moods.map(_moodChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _moodChip(Map<String, String> mood) {
    return GestureDetector(
      onTap: () => _sendMessage(mood['text']!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1826),
          border: Border.all(color: const Color(0xFF3D2B52)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '${mood['emoji']} ${mood['label']}',
          style: const TextStyle(color: Color(0xFFF0ABFC), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length) return _buildTypingIndicator();
        return _buildBubble(_messages[i]);
      },
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.isUser ? 'YOU' : 'FEEL',
              style: const TextStyle(
                color: Color(0xFFA78BBC),
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: msg.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF6D28D9), Color(0xFF9333EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: msg.isUser ? null : const Color(0xFF1E1826),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: const Color(0xFF2A1F35)),
                boxShadow: msg.isUser
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: const Color(0xFFF3E8FF),
                  fontSize: msg.isUser ? 14 : 15,
                  fontStyle: msg.isUser ? FontStyle.normal : FontStyle.italic,
                  height: 1.65,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1826),
          border: Border.all(color: const Color(0xFF2A1F35)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + (i * 160)),
              curve: Curves.easeInOut,
              builder: (_, val, __) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFF6D28D9),
                    const Color(0xFFC084FC),
                    val,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Input area ───────────────────────────
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0A0F),
        border: Border(top: BorderSide(color: Color(0xFF2A1F35))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              style: const TextStyle(color: Color(0xFFF3E8FF), fontSize: 14),
              decoration: InputDecoration(
                hintText: "Share what you're feeling...",
                hintStyle: const TextStyle(color: Color(0xFFA78BBC)),
                filled: true,
                fillColor: const Color(0xFF1E1826),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2A1F35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2A1F35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _isLoading ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isLoading ? null : () => _sendMessage(_controller.text),
            child: AnimatedOpacity(
              opacity: _isLoading ? 0.4 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D28D9), Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D28D9).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
