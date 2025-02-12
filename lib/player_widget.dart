import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  final String audioPath;

  const PlayerWidget({
    required this.player,
    super.key,
    required this.audioPath,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState; // Current player state (playing/paused/stopped)
  Duration? _duration; // Total audio duration
  Duration? _position; // Current playback position

  //Initiating Stream Subscription to get audio duration in case the user
  //records another audio
  StreamSubscription? _durationSubscription;
  //this Stream subscription tracks the position of the current playback in order to
  //display it
  StreamSubscription? _positionSubscription;
  //this Stream subscription is used to automatically stop the player on completion event
  StreamSubscription? _playerCompleteSubscription;
  //this Stream subscription is used to listen to state change of the player and assigns it
  //to _playerState variable
  StreamSubscription? _playerStateChangeSubscription;

  //these getter flags are used in the state management of the player
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  //these getters are used to display the current state of the player in the ui
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  //this getter is used to get the player instance passed from the application when this
  //widget is instantiated
  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    //Initializing player state and setup streams
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
          ],
        ),
        Slider(
          onChanged: (value) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = value * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void _initStreams() {
    //updating the player duration variable in case the user recorder another
    //audio
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    //listening and updating the current position of the player progress bar
    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    //automatically stopping the playback on complete event
    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    //listening for a change in the state of the player and updating our predefined state variable
    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  //this function provides the player with the recorder audio file path
  //then calls the resume function which plays the provided audio file
  //and updates the state variable
  Future<void> _play() async {
    await player.setSourceDeviceFile(widget.audioPath);
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  //this function pauses the playback
  //and updates the state variable
  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  //this function stops the playback, resets the position to zero
  //and updates the state variable
  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
