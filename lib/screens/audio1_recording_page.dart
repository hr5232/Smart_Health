import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class Audio1RecordingPage extends StatefulWidget {
  final String randomSentence;

  const Audio1RecordingPage({Key? key, required this.randomSentence})
      : super(key: key);

  @override
  _Audio1RecordingPageState createState() => _Audio1RecordingPageState();
}

class _Audio1RecordingPageState extends State<Audio1RecordingPage> {
  bool _isListening = false;
  bool _hasRecorded = false;
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  String _filePath = '';

  @override
  void initState() {
    super.initState();
    _handleMicrophonePermission();
  }

  Future<void> _handleMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _audioRecorder.openRecorder();
      await _audioPlayer.openPlayer();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Microphone Permission'),
        content: Text('Please grant microphone permission to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> startListening() async {
    var tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _audioRecorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> stopListening() async {
    await _audioRecorder.stopRecorder();
    setState(() {
      _isListening = false;
      _hasRecorded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording saved.')),
    );
  }

  Future<void> _playRecording() async {
    await _audioPlayer.startPlayer(
      fromURI: _filePath,
      codec: Codec.pcm16WAV,
    );
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recording'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please read the following sentence aloud:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.randomSentence,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'Listening...' : 'Record'),
              onPressed: _isListening ? stopListening : startListening,
            ),
            const SizedBox(height: 20),
            if (_hasRecorded)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Recording'),
                onPressed: _playRecording,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _filePath);
              },
              child: const Text('Back to Audio Input'),
            ),
          ],
        ),
      ),
    );
  }
}
