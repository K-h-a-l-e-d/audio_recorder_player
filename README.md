# Audio Record & Play App
## Description
This is a Simple flutter recorder/player application

## Features
- Recording user input and temporarily stores it in a directory
- Play, Pause & Stop audio playback control functionalities
- Duration display (MM:SS format)
- File path display for recorded audio
- Permission handling for microphone and storage
- State management for recording/playback sessions
## code explanation
- after getting mic & storage permissions from the user, on pressing record audio buttons a recording session starts and the mic start taking input from the user, synchronously a timer starts ticking which is used to store the duration of the recorded audio in duration variable which will be used as the playback max duration when playing the audio in a progress bar that will play displayed in the UI, and after the user has finished the recording on pressing stop recording button the recording session stops and the audio file is stored in the the path provided by The **path_provider** package instance temporar path.
- the player Progess UI & Control buttons appear in the UI only if the audio file exists in the prefined in the recorders, after the recorder has finished on pressing the play control button  the Player instance selects the passed prefined audio file path amd then calls the resume functions which starts playing the audio file.
- a Stream subscription for audio player is used to track the current progress of the playback, duration and completion states and update the UI with the state values obtained from listening to  onPositionChanged,onDurationChanged, onPlayerComplete events provided by **audioplayers** package.  
## Application Screenshots: 
|![recorder_s1](https://github.com/user-attachments/assets/186f232b-90e0-44f4-ac20-f2c44340bb72)|![recorder_s2](https://github.com/user-attachments/assets/a56dce59-7d48-4e5f-8693-513b7cadce94)|![recorder_s3](https://github.com/user-attachments/assets/4441f808-353b-4994-96ce-bc0ea7f29184)|
|-|-|-|
