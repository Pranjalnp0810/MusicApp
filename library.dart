import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_album/Database/service.dart';
import 'package:music_album/Database/usermodel.dart';
import 'package:music_album/albums/album1.dart';

class MyLibrary extends StatefulWidget {
  bool isComeFromAlbum;
  final Function(List<SongsModel>, int)? onPlay;
  final AudioPlayer? sharedPlayer;

  MyLibrary({
    super.key,
    this.isComeFromAlbum = false,
    this.onPlay,
    this.sharedPlayer,
  });

  @override
  State<MyLibrary> createState() => _MyLibraryState();
}

class _MyLibraryState extends State<MyLibrary> {
  int currentIndex = 0;
  List<SongsModel> songList = [];

  final List<SongsModel> defaultSongs = List.unmodifiable([
    SongsModel(
      id: 1,
      imagepath: 'assets/image/AppKiKashish.jpg',
      name: 'App Ki Kashish',
      subname: 'Himesh Reshammiya',
      path: 'assets/song/AppKiKashish.mp3',
      album: 'album1',
    ),

    SongsModel(
      id: 2,
      imagepath: 'assets/image/Cradles.jpg',
      name: 'Cradles',
      subname: 'Sub Urban',
      path: 'assets/song/Cradles_Ringtone__Download_Now_(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 3,
      imagepath: 'assets/image/Raanjhan.jpg',
      name: 'Raanjhan',
      subname: 'Sachet-Parampara',
      path:
          'assets/song/Full_Video__Raanjhan___Do_Patti___Kriti_Sanon,_Shaheer_Sheikh___Parampara_Tandon___Sachet-Parampara(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 4,
      imagepath: 'assets/image/Ilahi.jpg',
      name: 'Ilahi',
      subname: 'Pritam, Arijit Singh',
      path: 'assets/song/Ilahi_song_lyrics__arijit_singh_(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 5,
      imagepath: 'assets/image/Jhol.jpg',
      name: 'Jhol',
      subname: 'Jhol by LoFi Wav, its khushi',
      path:
          'assets/song/Jhol___Coke_Studio_Pakistan___Season_15___Maanu_x_Annural_Khalid(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 6,
      imagepath: 'assets/image/Diewithasmile.jpg',
      name: 'Die with a smile',
      subname: 'Lady Gaga, Bruno Mars',
      path:
          'assets/song/Lady_Gaga,_Bruno_Mars_-_Die_With_A_Smile__Lyrics_(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 7,
      imagepath: 'assets/image/co2.jpg',
      name: 'Co2',
      subname: 'Prateek Kuhad',
      path: 'assets/song/Prateek_Kuhad_-_Co2__Lyrics_(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 8,
      imagepath: 'assets/image/Saibore.jpg',
      name: 'Saibo re',
      subname: 'Kirtidan Gadhvi',
      path:
          'assets/song/SAIBO_RE_-_Kirtidan_Gadhvi,_Priya_Saraiya__સાઇબો_રે___New_Gujarati_Song_2020___Gujarati_Song_2020(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 9,
      imagepath: 'assets/image/Sanamterikasam.jpg',
      name: 'Sanam Teri kasam',
      subname: 'Himesh Reshammiya',
      path:
          'assets/song/Sanam_Teri_Kasam,__Lyrical_Video__-_Harshvardhan,_Mawra___Ankit_Tiwari___Palak_M___Himesh_Reshammiya(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 10,
      imagepath: 'assets/image/TuHainToMainHoon.jpg',
      name: 'Tu hai toh main hoon',
      subname: 'Arijit Singh, Afsana Khan',
      path:
          'assets/song/Tu_Hain_Toh_Main_Hoon___Sky_Force___Akshay,_Sara,_Veer,_Tanishk_B,_Arijit_Singh,_Afsana_Khan,_Irshad(256k).mp3',
      album: 'album1',
    ),
    SongsModel(
      id: 11,
      imagepath: 'assets/image/Yetunekyakiya.jpg',
      name: 'Ye tune kya kiya',
      subname: 'Once Upon A Time',
      path:
          'assets/song/Ye_Tune_Kya_Kiya_-_Javed_Bashir__Lyrics____Lyrical_Bam_Hindi(256k).mp3',
      album: 'album1',
    ),
  ]);

  @override
  void initState() {
    super.initState();
    songList = List.from(defaultSongs);
  }

  void playSelectedSong(int index) {
    for (var song in songList) {
      song.isPlay = false;
    }

    setState(() {
      songList[index].isPlay = true;
      currentIndex = index;
    });

    if (widget.onPlay != null) {
      widget.onPlay!(songList, index);
    }
  }

  Future<void> addSongInAlbum({
    required String imagepath,
    required String name,
    required String subname,
    required String songpath,
    required String album,
    required String isFavourite,
  }) async {
    var _userModel = UserModel();
    var _userService = Userservice();

    _userModel.imagepath = imagepath;
    _userModel.name = name;
    _userModel.subname = subname;
    _userModel.songpath = songpath;
    _userModel.isFavourite = isFavourite;
    _userModel.albumname = album;

    await _userService.saveUser(_userModel);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Album1(albumName: album)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song added to Album'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 8,
        shadowColor: Colors.black,
        leading:
            widget.isComeFromAlbum
                ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.greenAccent),
                )
                : SizedBox(),
        title: Text(
          "My Library",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
          ),
        ),
        actions: const [Icon(Icons.settings, color: Colors.white)],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: songList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap:
                  widget.isComeFromAlbum ? null : () => playSelectedSong(index),
              leading: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: AssetImage(songList[index].imagepath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                songList[index].name.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      songList[index].isPlay
                          ? Colors.greenAccent
                          : Colors.black,
                ),
              ),
              subtitle: Text(songList[index].subname.toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (songList[index].isPlay) 
                    Icon(Icons.graphic_eq, color: Colors.greenAccent,),
                    widget.isComeFromAlbum
                        ? IconButton(
                          onPressed: () async {
                            addSongInAlbum(
                              imagepath: songList[index].imagepath,
                              name: songList[index].name,
                              subname: songList[index].subname,
                              songpath: songList[index].path,
                              album: songList[index].album ?? '',
                              isFavourite: 'false',
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.black,
                            size: 30,
                          ),
                        )
                        : const Icon(Icons.more_vert),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SongsModel {
  final int id;
  final String imagepath;
  final String name;
  final String subname;
  final String path;
  final String? album;
  bool isPlay;
  bool isFavourite;
  SongsModel({
    required this.id,
    required this.imagepath,
    required this.name,
    required this.subname,
    required this.path,
    required this.album,
    this.isPlay = false,
    this.isFavourite = false,
  });
}
