// i want to build an app like HR app. It includes attandance, salary, taskmanager, CRM. In attandance it includes present, absent, paid leaves, sick leaves, etc. In salary section it includes salary of all employees, monthly salary, monthly incentive, extra payout, etc. In taskmanager it includes we can give task to particular employee or Team Leader (TL), it shows the task as pending, completed or snoozed as per the status. In Customer Relationship Management (CRM) it includes managing clients, leads, follow-ups, status pipelines(cold lead, active, converted), etc.
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_album/library.dart';
import 'package:rxdart/rxdart.dart';

class MyMusicPlayerScreen extends StatefulWidget {
  final List<SongsModel> songs;
  final int currentIndex;
  final AudioPlayer player;

  final bool Function(SongsModel song)? isFavourite;
  final void Function(SongsModel song)? onToggleFavourite;

  const MyMusicPlayerScreen({
    super.key,
    required this.songs,
    required this.currentIndex,
    required this.player,
    this.isFavourite,
    this.onToggleFavourite,
  });

  @override
  State<MyMusicPlayerScreen> createState() => _MyMusicPlayerScreenState();
}

class _MyMusicPlayerScreenState extends State<MyMusicPlayerScreen> {
  late ConcatenatingAudioSource _playlist;
  late AudioPlayer _player;
  late int _currentIndex;
  late SongsModel _currentSong;
  bool isPlaying = true;
  bool isShuffle = false;
  bool isRepeat = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _player = widget.player;
  //   _currentIndex = widget.currentIndex;
  //   _currentSong = widget.songs[_currentIndex];

  //   _playlist = ConcatenatingAudioSource(
  //     children:
  //         widget.songs.map((song) => AudioSource.asset(song.path)).toList(),
  //   );

  //   if (!(_player.audioSource is ConcatenatingAudioSource) ||
  //       (_player.audioSource as ConcatenatingAudioSource).children.length !=
  //           _playlist.children.length) {
  //     _player.setAudioSource(_playlist, initialIndex: _currentIndex).then((_) {
  //       _player.play();
  //     });
  //   }

  //   setState(() {
  //     isShuffle = _player.shuffleModeEnabled;
  //     isRepeat = _player.loopMode == LoopMode.one;
  //   });

  //   _player.currentIndexStream.listen((index) {
  //     if (index != null && index >= 0 && index < widget.songs.length) {
  //       setState(() {
  //         _currentIndex = index;
  //         _currentSong = widget.songs[_currentIndex];

  //         for (int i = 0; i < widget.songs.length; i++) {
  //           widget.songs[i].isPlay = i == _currentIndex;
  //         }
  //       });
  //     }
  //   });

  //   _player.playerStateStream.listen((state) async {
  //     if (state.processingState == ProcessingState.completed) {
  //       final loopMode = await _player.loopMode;
  //       if (loopMode != LoopMode.one) {
  //         _player.seekToNext();
  //       }
  //     }
  //   });

  //   _player.playingStream.listen((playing) {
  //     setState(() {
  //       isPlaying = playing;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _currentIndex = widget.currentIndex;
    _currentSong = widget.songs[_currentIndex];

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _playlist = ConcatenatingAudioSource(
      children:
          widget.songs.map((song) => AudioSource.asset(song.path)).toList(),
    );

    final audioSource = _player.audioSource;
    if (audioSource == null ||
        (audioSource is! ConcatenatingAudioSource) ||
        audioSource.children.length != _playlist.children.length) {
      await _player.setAudioSource(_playlist, initialIndex: _currentIndex);
      await _player.play();
    }

    final loopMode = await _player.loopMode;
    final shuffleMode = await _player.shuffleModeEnabled;

    setState(() {
      isRepeat = loopMode == LoopMode.one;
      isShuffle = shuffleMode;
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < widget.songs.length) {
        setState(() {
          _currentIndex = index;
          _currentSong = widget.songs[_currentIndex];
          for (int i = 0; i < widget.songs.length; i++) {
            widget.songs[i].isPlay = i == _currentIndex;
          }
        });
      }
    });

    _player.playingStream.listen((playing) {
      setState(() {
        isPlaying = playing;
      });
    });

    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        final loopMode = await _player.loopMode;
        if (loopMode != LoopMode.one) {
          _player.seekToNext();
        }
      }
    });
  }

  void _playNext() {
    _player.seekToNext();
  }

  void _playPrevious() {
    _player.seekToPrevious();
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
        _player.positionStream,
        _player.durationStream,
        (position, duration) =>
            DurationState(position: position, total: duration ?? Duration.zero),
      );

  @override
  void dispose() {
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  // Future<void> _loadAndPlaySong(SongsModel song) async {
  //   final currentSource = _player.audioSource;

  //   if (currentSource is ConcatenatingAudioSource &&
  //       _player.currentIndex == _currentIndex) {
  //     return;
  //   }

  //   try {
  //     final playlist = ConcatenatingAudioSource(
  //       children: widget.songs.map((s) => AudioSource.asset(s.path)).toList(),
  //     );

  //     await _player.setAudioSource(playlist, initialIndex: _currentIndex);
  //     await _player.play();
  //   } catch (e) {
  //     print("Error loading song: $e");
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Failed to play song")));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bool fav = widget.isFavourite?.call(_currentSong) ?? false;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _currentIndex);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, _currentIndex);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(_currentSong.name),
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _currentSong.imagepath,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  _currentSong.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  _currentSong.subname,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade300),
                ),
                SizedBox(height: 12),
                IconButton(
                  icon: Icon(
                    (widget.isFavourite?.call(_currentSong) ?? false)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        (widget.isFavourite?.call(_currentSong) ?? false)
                            ? Colors.redAccent
                            : Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    widget.onToggleFavourite?.call(_currentSong);
                    setState(() {});
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    setState(() {
                      isShuffle = !isShuffle;
                    });
                    await _player.setShuffleModeEnabled(isShuffle);
                    if (isShuffle) {
                      await _player.shuffle();
                    }
                  },
                  icon: Icon(
                    Icons.shuffle,
                    color: isShuffle ? Colors.greenAccent : Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isRepeat = !isRepeat;
                      _player.setLoopMode(
                        isRepeat ? LoopMode.one : LoopMode.off,
                      );
                    });
                  },
                  icon: Icon(
                    isRepeat ? Icons.repeat_one : Icons.repeat,
                    color: isRepeat ? Colors.greenAccent : Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            StreamBuilder<DurationState>(
              stream: _durationStateStream,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final position = durationState?.position ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      activeColor: Colors.greenAccent,
                      inactiveColor: Colors.white24,
                      min: 0,
                      max:
                          total.inSeconds == 0 ? 1 : total.inSeconds.toDouble(),
                      value:
                          position.inSeconds
                              .clamp(0, total.inSeconds)
                              .toDouble(),
                      onChanged: (value) {
                        _player.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(position),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            formatDuration(total),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    color: _currentIndex > 0 ? Colors.white : Colors.grey,
                    size: 40,
                  ),
                  onPressed: _currentIndex > 0 ? _playPrevious : null,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                    ),
                    iconSize: 64,
                    color: Colors.greenAccent,
                    onPressed: _togglePlayPause,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color:
                        _currentIndex < widget.songs.length - 1
                            ? Colors.white
                            : Colors.grey,
                    size: 40,
                  ),
                  onPressed:
                      _currentIndex < widget.songs.length - 1
                          ? _playNext
                          : null,
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState({required this.position, required this.total});
}
