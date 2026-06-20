import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wellness_buddy_client/wellness_buddy_client.dart';
import '../main.dart' show client, AaraColors;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatBubble> _bubbles = [];
  final List<ChatMessage> _history = [];

  bool _isTyping = false;
  bool _showCrisisBanner = false;
  late AnimationController _typingAnimController;

  static const _crisisKeywords = [
    'want to die',
    'end it',
    'kill myself',
    'not worth living',
    'disappear',
    'everyone better without me',
    'suicide',
  ];

  static const _quickChips = [
    ('😰', 'I\'m really anxious'),
    ('😔', 'I\'m feeling low'),
    ('😤', 'I\'m overwhelmed'),
    ('😴', 'I\'m exhausted'),
    ('📚', 'Can\'t focus on studies'),
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _bubbles.add(_ChatBubble(
      role: 'model',
      content:
          'Namaste 🙏 I\'m Aara — I\'m here to just be with you, however you\'re feeling right now.\n\nYou can talk to me about what\'s weighing on you. No agenda. No judgment. What\'s on your mind today?',
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  bool _checkCrisis(String text) {
    final lower = text.toLowerCase();
    return _crisisKeywords.any((kw) => lower.contains(kw));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    final userMsg = ChatMessage(
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now().toUtc(),
    );

    setState(() {
      _bubbles.add(_ChatBubble(
        role: 'user',
        content: text.trim(),
        timestamp: DateTime.now(),
      ));
      _history.add(userMsg);
      _isTyping = true;
      _textController.clear();
      if (_checkCrisis(text)) _showCrisisBanner = true;
    });

    _scrollToBottom();

    try {
      final historyToSend = _history.length > 1
          ? _history.sublist(0, _history.length - 1)
          : <ChatMessage>[];
      final reply = await client.chat.sendMessage(historyToSend, text.trim());

      setState(() {
        _isTyping = false;
        _bubbles.add(_ChatBubble(
          role: 'model',
          content: reply.content,
          timestamp: reply.timestamp.toLocal(),
        ));
        _history.add(reply);
        if (_checkCrisis(reply.content)) _showCrisisBanner = true;
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _bubbles.add(_ChatBubble(
          role: 'model',
          content:
              'I\'m here, but something went wrong on my end. Please try again in a moment 💜',
          timestamp: DateTime.now(),
        ));
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AaraColors.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_showCrisisBanner) _buildCrisisBanner(),
          Expanded(child: _buildMessageList()),
          _buildQuickChips(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AaraColors.bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AaraColors.iceCold, AaraColors.purplePain],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AaraColors.purplePain.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aara',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Here for you',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AaraColors.heavyPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded,
              color: AaraColors.heavyPurple.withValues(alpha: 0.8)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCrisisBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: Color(0xFFEF4444), size: 16),
              const SizedBox(width: 8),
              Text(
                'You\'re not alone. Please reach out:',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showCrisisBanner = false),
                child: const Icon(Icons.close_rounded,
                    color: AaraColors.heavyPurple, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _crisisLine('iCall Helpline', '9152987821',
              'Mon–Sat, 8am–10pm · Hindi & English'),
          const SizedBox(height: 4),
          _crisisLine('Vandrevala Foundation', '1860-2662-345',
              '24/7 · Free · Multilingual'),
        ],
      ),
    );
  }

  Widget _crisisLine(String name, String number, String note) {
    return Row(
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.nunito(
                  fontSize: 12, color: AaraColors.heavyPurple),
              children: [
                TextSpan(
                    text: '$name: ',
                    style: const TextStyle(color: Colors.white)),
                TextSpan(
                  text: number,
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: '  ·  $note'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _bubbles.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _bubbles.length) {
          return _buildTypingBubble();
        }
        return _buildBubble(_bubbles[index]);
      },
    );
  }

  Widget _buildBubble(_ChatBubble bubble) {
    final isUser = bubble.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AaraColors.iceCold, AaraColors.purplePain],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'A',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // User bubble: Purple Pain gradient
                gradient: isUser
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF6B3A90),
                          Color(0xFF4A2060),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                // Aara bubble: dark surface with ice-cold border tint
                color: isUser ? null : AaraColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: AaraColors.iceCold.withValues(alpha: 0.15),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                bubble.content,
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.95)
                      : AaraColors.freezePurple,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AaraColors.iceCold, AaraColors.purplePain],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AaraColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                  color: AaraColors.iceCold.withValues(alpha: 0.15), width: 1),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.33;
                    final phase = ((_typingAnimController.value - delay) % 1.0 + 1.0) % 1.0;
                    final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AaraColors.border,
                          AaraColors.iceCold,
                          t,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final chip = _quickChips[i];
          return GestureDetector(
            onTap: () => _sendMessage(chip.$2),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AaraColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AaraColors.iceCold.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Text(chip.$1, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    chip.$2,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AaraColors.medPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AaraColors.bg,
        border: Border(
          top: BorderSide(color: AaraColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AaraColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AaraColors.border),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 1,
                style: GoogleFonts.nunito(
                  color: AaraColors.freezePurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Tell Aara what\'s on your mind...',
                  hintStyle: GoogleFonts.nunito(
                    color: AaraColors.hintText,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AaraColors.iceCold, AaraColors.purplePain],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AaraColors.purplePain.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
    );
  }
}

class _ChatBubble {
  final String role;
  final String content;
  final DateTime timestamp;
  _ChatBubble({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}
