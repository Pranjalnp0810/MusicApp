import 'package:flutter/material.dart';
import 'package:music_album/dashboard.dart';
import 'package:music_album/favourite.dart';
import 'package:music_album/library.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_album/musicplayerscreen.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int index_value = 0;
  final AudioPlayer player = AudioPlayer();
  bool isPlay = false;
  bool showMiniPlayer = false;
  int? currentIndex;
  List<SongsModel> currentPlaylist = [];
  List<SongsModel> favouriteSongs = [];

  void changeIndex(int index) {
    setState(() {
      index_value = index;
    });
  }

  void playSong(List<SongsModel> songs, int index) async {
    setState(() {
      currentPlaylist = songs;
      currentIndex = index;
      isPlay = true;
      showMiniPlayer = true;
    });

    try {
      final playlist = ConcatenatingAudioSource(
        children: songs.map((song) => AudioSource.asset(song.path)).toList(),
      );

      await player.setAudioSource(playlist, initialIndex: index);
      await player.play();
    } catch (e) {
      print('Error playing song: $e');
      setState(() {
        isPlay = false;
        showMiniPlayer = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    player.playingStream.listen((playing) {
      if (isPlay != playing) {
        setState(() {
          isPlay = playing;
        });
      }
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNextSong();
      }
    });
  }

  void playNextSong() {
    player.seekToNext();
  }

  void toggleFavourite(SongsModel song) {
    setState(() {
      if (favouriteSongs.contains(song)) {
        favouriteSongs.remove(song);
      } else {
        favouriteSongs.add(song);
      }
    });
  }

  List<Widget> get mylist => [
    MyDashboard(onPlay: playSong, sharedPlayer: player),
    MyDashboard(),
    MyFavouriteScreen(),
    MyLibrary(onPlay: playSong, sharedPlayer: player),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mylist.elementAt(index_value),
      bottomSheet: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 1),
              end: Offset(0, 0),
            ).animate(animation),
            child: child,
          );
          // SizeTransition(
          //   sizeFactor: animation,
          //   axisAlignment: -1.0,
          //   child: child,
          // );
        },
        child:
            showMiniPlayer && currentIndex != null
                ? GestureDetector(
                  key: ValueKey('miniPlayer'),
                  onTap: () {
                    Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MyMusicPlayerScreen(
                              songs: currentPlaylist,
                              currentIndex: currentIndex!,
                              player: player,
                              isFavourite:
                                  (song) => favouriteSongs.contains(song),
                              onToggleFavourite: toggleFavourite,
                            ),
                      ),
                    ).then((newIndex) {
                      if (newIndex != null && newIndex is int) {
                        setState(() {
                          currentIndex = newIndex;
                          showMiniPlayer = true;
                        });
                      }
                    });
                  },
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            currentPlaylist[currentIndex!].imagepath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentPlaylist[currentIndex!].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentPlaylist[currentIndex!].subname,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlay
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.greenAccent,
                            size: 40,
                          ),
                          onPressed: () async {
                            if (player.playing) {
                              await player.pause();
                            } else {
                              await player.play();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
                : const SizedBox.shrink(key: ValueKey('empty')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favourite",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Library"),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: index_value,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.white),
        onTap: changeIndex,
        backgroundColor: Colors.black,
      ),
    );
  }
}
