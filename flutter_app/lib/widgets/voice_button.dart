import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key, required this.text, required this.languageCode});
  final String text;
  final String languageCode;

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  final FlutterTts _tts = FlutterTts();
  String state = 'idle';

  Future<void> _play() async {
    setState(() => state = 'playing');
    await _tts.setLanguage(widget.languageCode);
    await _tts.speak(widget.text);
    setState(() => state = 'done');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _play,
      icon: Icon(state == 'playing' ? Icons.volume_up : Icons.play_arrow),
      label: Text(state == 'done' ? 'Played' : 'Listen'),
    );
  }
}
