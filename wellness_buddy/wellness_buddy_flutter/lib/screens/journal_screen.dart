import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wellness_buddy_client/wellness_buddy_client.dart';
import '../main.dart' show client, AaraColors;

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  JournalAnalysis? _analysis;
  String? _errorMessage;

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysis = null;
    });

    try {
      final analysis = await client.journal.analyzeJournal(text);
      setState(() => _analysis = analysis);
    } catch (e) {
      final raw = e.toString();
      String friendly;
      if (raw.contains('statusCode = 500') || raw.contains('Internal server error')) {
        friendly = '⚠️ The server ran into a problem analyzing your journal.\n\nMake sure:\n• Your Gemini API key is set in passwords.yaml\n• The Serverpod server was restarted after setting the key';
      } else if (raw.contains('SocketException') || raw.contains('Connection refused')) {
        friendly = '📡 Cannot reach the server. Is Serverpod running?\n\nRun: dart run bin/main.dart in the server folder.';
      } else if (raw.contains('model') && raw.contains('not found')) {
        friendly = '🤖 The AI model is unavailable. The server may need to be restarted.';
      } else {
        friendly = raw.replaceFirst(RegExp(r'^Exception: '), '');
      }
      setState(() => _errorMessage = friendly);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _severityColor(int severity) {
    if (severity <= 3) return const Color(0xFF4ADE80);
    if (severity <= 6) return const Color(0xFFFBBF24);
    return const Color(0xFFEF4444);
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Exam Pressure':       return Icons.school_rounded;
      case 'Academic Performance':return Icons.bar_chart_rounded;
      case 'Mock Test Scores':    return Icons.quiz_rounded;
      case 'Time Management':     return Icons.timer_rounded;
      case 'Family Expectations': return Icons.family_restroom_rounded;
      case 'Peer Comparison':     return Icons.people_rounded;
      case 'Sleep Problems':      return Icons.bedtime_rounded;
      case 'Health Issues':       return Icons.favorite_rounded;
      case 'Future Uncertainty':  return Icons.help_outline_rounded;
      case 'Relationship Issues': return Icons.handshake_rounded;
      case 'Financial Concerns':  return Icons.currency_rupee_rounded;
      default:                    return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AaraColors.bg,
      appBar: AppBar(
        backgroundColor: AaraColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Journal Reflect',
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Aara finds hidden stress patterns',
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: AaraColors.heavyPurple,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 20),
            _buildJournalInput(),
            const SizedBox(height: 16),
            _buildAnalyzeButton(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(),
            ],
            if (_analysis != null) ...[
              const SizedBox(height: 24),
              _buildResultsHeader(),
              const SizedBox(height: 12),
              ..._analysis!.triggers.map(_buildTriggerCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AaraColors.iceCold.withValues(alpha: 0.12),
            AaraColors.purplePain.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AaraColors.iceCold.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          const Text('📝', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Write or paste your journal entry below. Aara will identify hidden stress triggers — no judgment.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AaraColors.medPurple,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalInput() {
    return Container(
      decoration: BoxDecoration(
        color: AaraColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AaraColors.border),
      ),
      child: TextField(
        controller: _controller,
        maxLines: 8,
        style: GoogleFonts.nunito(
          color: AaraColors.freezePurple,
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText:
              'Today I felt... / I\'m struggling with... / What happened today was...',
          hintStyle: GoogleFonts.nunito(
            color: AaraColors.hintText,
            fontSize: 14,
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : const LinearGradient(
                  colors: [AaraColors.purplePain, Color(0xFF5C3080)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: _isLoading ? AaraColors.border : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: AaraColors.purplePain.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _analyze,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AaraColors.iceCold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Aara is reading...',
                      style: GoogleFonts.nunito(
                        color: AaraColors.medPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Reveal Stress Triggers',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.nunito(
                  color: const Color(0xFFEF4444), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      children: [
        const Icon(Icons.insights_rounded, color: AaraColors.iceCold, size: 20),
        const SizedBox(width: 8),
        Text(
          '${_analysis!.triggers.length} Trigger${_analysis!.triggers.length != 1 ? 's' : ''} Found',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTriggerCard(StressTrigger trigger) {
    final color = _severityColor(trigger.severity);
    final icon = _categoryIcon(trigger.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AaraColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AaraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                  bottom: BorderSide(color: color.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    trigger.trigger,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${trigger.severity}/10',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category chip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AaraColors.purplePain.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AaraColors.purplePain.withValues(alpha: 0.3)),
              ),
              child: Text(
                trigger.category,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AaraColors.medPurple,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // Evidence
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVIDENCE',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AaraColors.labelText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AaraColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AaraColors.iceCold.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    '"${trigger.evidence}"',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AaraColors.freezePurple,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Explanation
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHAT THIS MEANS',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AaraColors.labelText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  trigger.explanation,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AaraColors.heavyPurple,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
