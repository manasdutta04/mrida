import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Plays TTS for prescription text.
/// States: idle → playing → done.
class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key, required this.text, required this.languageCode});
  final String text;
  final String languageCode;

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  final FlutterTts _tts = FlutterTts();
  String _state = 'idle'; // idle | playing | done

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _state = 'done');
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _play() async {
    if (_state == 'playing') {
      await _tts.stop();
      setState(() => _state = 'idle');
      return;
    }
    setState(() => _state = 'playing');
    await _tts.setLanguage(widget.languageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(widget.text);
  }

  IconData get _icon {
    switch (_state) {
      case 'playing':
        return Icons.stop_rounded;
      case 'done':
        return Icons.replay_rounded;
      default:
        return Icons.volume_up_rounded;
    }
  }

  String get _label {
    switch (_state) {
      case 'playing':
        return 'Stop';
      case 'done':
        return 'Replay';
      default:
        return 'Listen';
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _play,
      icon: Icon(_icon, size: 20),
      label: Text(
        _label,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: MridaColors.primary,
        side: BorderSide(color: MridaColors.primary.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
      ),
    );
  }
}
