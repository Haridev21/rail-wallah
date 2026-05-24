import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;


const String _geminiApiKey = 'AIzaSyAZUrl_u9yQjM2n3ZGuWtfdn-l5efCOsGU';
const String _geminiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey';



const String _systemPrompt = '''
You are Rail Wallah AI, a friendly and professional AI support assistant for Rail Wallah — a Railway Passenger Support System.
Your role is to help train passengers with any questions or issues they face during their journey.

PERSONALITY:
- Warm, helpful, and reassuring — passengers may be stressed or confused.
- Concise and clear — most passengers read on mobile while traveling.
- Professional but not robotic; use natural, human language.

SCOPE — You assist with:
1. Train schedules, delays, cancellations, and platform changes.
2. Ticket booking, cancellation, refund policies, and seat reservations.
3. Lost & found procedures — how to report lost items on trains or stations.
4. Complaints and feedback — guide passengers on how to file formal complaints.
5. Safety emergencies — provide calm, immediate guidance and emergency contacts.
6. Platform & station information — amenities, accessibility, waiting rooms, ATMs, etc.
7. General railway rules, luggage policies, and passenger rights.

RULES:
- If asked about a specific train number, PNR status, or real-time data, explain you cannot access live systems but guide them to the official app/website or helpline number 139.
- Never make up train times or ticket prices — always advise checking official sources.
- For genuine emergencies (medical, fire, criminal), always say: "Please pull the emergency chain / press the emergency button AND call 112 immediately."
- Keep responses under 150 words unless the passenger clearly needs detailed instructions.
- If the passenger's question is outside railway topics, politely redirect: "I'm specialized in railway support — for that, you may need to contact a different service."
- Always end with a follow-up offer: "Is there anything else I can help you with?"

LANGUAGE:
- Respond in the same language the passenger uses (English, Hindi, etc.).
- Use simple vocabulary; avoid jargon.
''';



class _QuickOption {
  final String label;
  final IconData icon;
  final String prompt;

  const _QuickOption({
    required this.label,
    required this.icon,
    required this.prompt,
  });
}

const List<_QuickOption> _quickOptions = [
  _QuickOption(
    label: 'Train Schedule & Delays',
    icon: Icons.schedule_rounded,
    prompt:
        'How can I check my train schedule and find out if my train is delayed?',
  ),
  _QuickOption(
    label: 'Ticket Booking Help',
    icon: Icons.confirmation_number_rounded,
    prompt:
        'I need help with booking, cancelling, or getting a refund for my ticket.',
  ),
  _QuickOption(
    label: 'Lost & Found',
    icon: Icons.search_rounded,
    prompt:
        'I lost something on the train or at the station. What should I do?',
  ),
  _QuickOption(
    label: 'Complaint / Feedback',
    icon: Icons.feedback_rounded,
    prompt: 'I want to file a complaint or give feedback about my journey.',
  ),
  _QuickOption(
    label: '🚨 Safety Emergency',
    icon: Icons.warning_amber_rounded,
    prompt:
        'I have a safety emergency on the train. What should I do right now?',
  ),
  _QuickOption(
    label: 'Platform & Station Info',
    icon: Icons.train_rounded,
    prompt:
        'What facilities are available at my station? Where is my platform?',
  ),
];



class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _ChatMessage({required this.text, required this.isUser})
    : time = DateTime.now();
}



class _AiUiState {
  const _AiUiState({
    this.messages = const [],
    this.isLoading = false,
    this.showQuickOptions = true,
  });

  final List<_ChatMessage> messages;
  final bool isLoading;
  final bool showQuickOptions;

  _AiUiState copyWith({
    List<_ChatMessage>? messages,
    bool? isLoading,
    bool? showQuickOptions,
  }) {
    return _AiUiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      showQuickOptions: showQuickOptions ?? this.showQuickOptions,
    );
  }
}

class _AiUiNotifier extends StateNotifier<_AiUiState> {
  _AiUiNotifier() : super(const _AiUiState());

  void resetWithGreeting(_ChatMessage greeting) {
    state = _AiUiState(
      messages: [greeting],
      isLoading: false,
      showQuickOptions: true,
    );
  }

  void appendUserMessage(_ChatMessage msg) {
    state = state.copyWith(
      messages: [...state.messages, msg],
      isLoading: true,
      showQuickOptions: false,
    );
  }

  void appendBotMessage(_ChatMessage msg) {
    state = state.copyWith(
      messages: [...state.messages, msg],
      isLoading: false,
    );
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }
}

final _aiUiProvider =
    StateNotifierProvider.autoDispose<_AiUiNotifier, _AiUiState>(
      (ref) => _AiUiNotifier(),
    );

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen>
    with TickerProviderStateMixin {
  final List<Map<String, String>> _history = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Theme colors — Red Railway
  static const Color _primaryRed = Color(0xFF7B0000); // deep crimson
  static const Color _accentRed = Color(0xFFD32F2F); // vivid red
  static const Color _emergencyRed = Color(0xFFB71C1C); // dark emergency
  static const Color _bgColor = Color(0xFFFFF5F5); // warm near-white

  @override
  void initState() {
    super.initState();
    ref
        .read(_aiUiProvider.notifier)
        .resetWithGreeting(
          _ChatMessage(
            text:
                "👋 Hello! I'm **Rail Wallah AI**, your AI support companion.\n\nI can help you with schedules, tickets, lost items, complaints, and more.\n\nTap a quick option below or type your question!",
            isUser: false,
          ),
        );
  }

  

  Future<String> _callGemini(String userMessage, {int retries = 3}) async {
    final List<Map<String, dynamic>> contents = [];

    for (final turn in _history) {
      contents.add({
        'role': turn['role'],
        'parts': [
          {'text': turn['text']},
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage},
      ],
    });

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': contents,
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
    });

    for (int attempt = 0; attempt < retries; attempt++) {
      final response = await http.post(
        Uri.parse(_geminiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        _history.add({'role': 'user', 'text': userMessage});
        _history.add({'role': 'model', 'text': text});
        return text;
      } else if (response.statusCode == 429 && attempt < retries - 1) {
        // Rate limited — wait and retry
        debugPrint('Rate limited, retrying in ${(attempt + 1) * 10}s...');
        await Future.delayed(Duration(seconds: (attempt + 1) * 10));
        continue;
      } else {
        throw Exception(
          'Gemini error ${response.statusCode}: ${response.body}',
        );
      }
    }
    throw Exception('Max retries reached. Please try again in a moment.');
  }

  

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    ref
        .read(_aiUiProvider.notifier)
        .appendUserMessage(_ChatMessage(text: text, isUser: true));
    _scrollToBottom();

    try {
      final reply = await _callGemini(text);
      ref
          .read(_aiUiProvider.notifier)
          .appendBotMessage(_ChatMessage(text: reply, isUser: false));
    } catch (e) {
      debugPrint('Gemini Error: $e');
      final isRateLimit =
          e.toString().contains('429') || e.toString().contains('quota');
      ref
          .read(_aiUiProvider.notifier)
          .appendBotMessage(
            _ChatMessage(
              text: isRateLimit
                  ? "⏳ The AI is a bit busy right now (rate limit). Please wait a few seconds and try again.\n\nFor urgent help, call Railway Helpline **139**."
                  : "⚠️ Sorry, I couldn't connect right now. Please check your internet and try again.\n\nFor urgent help, call Railway Helpline **139**.",
              isUser: false,
            ),
          );
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final vm = ref.watch(_aiUiProvider);
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                ...vm.messages.map((m) => _buildBubble(m)),
                if (vm.showQuickOptions) _buildQuickOptions(),
                if (vm.isLoading) _buildTypingIndicator(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryRed,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _accentRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rail Wallah AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Rail Wallah',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'New conversation',
          onPressed: _resetChat,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _resetChat() {
    _history.clear();
    ref
        .read(_aiUiProvider.notifier)
        .resetWithGreeting(
          _ChatMessage(
            text:
                "👋 Hello! I'm **Rail Wallah AI**, your AI support companion.\n\nI can help you with schedules, tickets, lost items, complaints, and more.\n\nTap a quick option below or type your question!",
            isUser: false,
          ),
        );
  }

  

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.isUser;
    final isEmergency = !isUser && msg.text.toLowerCase().contains('emergency');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isEmergency
              ? const Color(0xFFFFEBEE)
              : isUser
              ? _accentRed
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isEmergency
              ? Border.all(color: _emergencyRed, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy_rounded,
                      size: 13,
                      color: isEmergency ? _emergencyRed : _accentRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEmergency ? 'EMERGENCY ALERT' : 'Rail Wallah AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isEmergency ? _emergencyRed : _accentRed,
                      ),
                    ),
                  ],
                ),
              ),
            _parseMarkdown(msg.text, isUser),
            const SizedBox(height: 4),
            Text(
              '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isUser ? Colors.white60 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple bold-text markdown parser for **text**
  Widget _parseMarkdown(String text, bool isUser) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.5,
          height: 1.45,
          color: isUser ? Colors.white : Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  

  Widget _buildQuickOptions() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Quick Help Topics',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickOptions
                .map(
                  (opt) => _QuickChip(
                    option: opt,
                    onTap: () => _sendMessage(opt.prompt),
                    isEmergency: opt.label.contains('Emergency'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 14, color: _accentRed),
            const SizedBox(width: 8),
            _DotLoader(),
          ],
        ),
      ),
    );
  }

  

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your journey...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: _bgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: _accentRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _QuickChip extends StatelessWidget {
  final _QuickOption option;
  final VoidCallback onTap;
  final bool isEmergency;

  const _QuickChip({
    required this.option,
    required this.onTap,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEmergency
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEmergency
                ? const Color(0xFFB71C1C)
                : const Color(0xFFD32F2F),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 14,
              color: isEmergency
                  ? const Color(0xFFB71C1C)
                  : const Color(0xFF7B0000),
            ),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isEmergency
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFF7B0000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _DotLoader extends StatefulWidget {
  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, c) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
          final opacity = (t < 0.5 ? t * 2 : (1.0 - t) * 2).clamp(0.3, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
