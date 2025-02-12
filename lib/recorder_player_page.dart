import 'dart:async';
import 'package:audio_record_play/player_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Audio extends StatefulWidget {
  const Audio({super.key, required this.title});

  final String title;

  @override
  State<Audio> createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  //instantiating an object for recording and storing an audo file
  final FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();
  //instantiating an object for playing the stored audo file
  final AudioPlayer player = AudioPlayer();

  //this path will be used for storing the recorded audio file
  String? audioPath;

  //Recording timer variables
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    //requesting user for mic & storage permissions and initializing the recorder
    //upon calling the current widget
    requestPermissions();
    initializeRecorder();
    //Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> initializeRecorder() async {
    await audioRecorder.openRecorder();
  }

  Future<void> requestPermissions() async {
    //asking user for mic and storage permissions
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> startRecording() async {
    //getting an instance of a temporar diretory & defining a path in that directory
    //for storing the audio file
    final directory = await getDownloadsDirectory();
    final path = '${directory!.path}/audio.aac';

    //calling the start recorder function and passing 2 arguments, the predefined path for storing
    //the audio file & the extension or codec type of the audio file (eg. mp3, aacADTS..etc)
    await audioRecorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );

    setState(() {
      audioPath = path;
      _recordingDuration = Duration.zero;
    });

    //Start recording timer which updates the recording duration variable value every 1 second
    //while the recorder is running
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  Future<void> stopRecording() async {
    await audioRecorder.stopRecorder();
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  //calling the close recorder & player in dispose function to release mic and audio resources
  //also disposing after navigating from the current widget or closing the app
  //to prevent memory leaks and for better performance
  @override
  void dispose() {
    audioRecorder.closeRecorder();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder/Player'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              //toggling between start/stop recording functions depending on the current status
              //of isRecording flag
              onPressed:
                  audioRecorder.isRecording ? stopRecording : startRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    audioRecorder.isRecording ? Colors.red : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
              //changing the button text depending on the status of isRecording flag
              child: Text(audioRecorder.isRecording
                  ? 'Stop Recording'
                  : 'Start Recording'),
            ),
            const SizedBox(height: 10),
            // Recording duration display
            if (audioRecorder.isRecording)
              Text(
                'Recording: ${_formatDuration(_recordingDuration)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            //showing the player widget only if an audio file exists in our prefined path
            if (audioPath != null)
              audioRecorder.isRecording
                  ? const SizedBox()
                  : PlayerWidget(
                      player: player,
                      audioPath: audioPath!,
                    ),
            const SizedBox(height: 20),
            //displaying the path of the recorded audio
            if (audioPath != null) Text('Audio file path: $audioPath'),
          ],
        ),
      ),
    );
  }
}
