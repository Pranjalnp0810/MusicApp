import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_album/Database/service.dart';
import 'package:music_album/Database/usermodel.dart';
import 'package:music_album/bottomBar.dart';
import 'package:music_album/library.dart';

enum Option { delete }

class Album1 extends StatefulWidget {
  final String albumName;
  final Function(List<SongsModel>, int)? onPlay;
  final AudioPlayer? sharedPlayer;
  const Album1({
    super.key,
    required this.albumName,
    this.onPlay,
    this.sharedPlayer,
  });

  @override
  State<Album1> createState() => _Album1State();
}

class _Album1State extends State<Album1> {
  List<UserModel> myList = <UserModel>[];
  final Userservice _userService = Userservice();

  @override
  void initState() {
    super.initState();
    fetchAlbumSongs();
  }

  Future<void> fetchAlbumSongs() async {
    var data = await _userService.displayUser();
    setState(() {
      myList =
          data
              .map((raw) {
                var user = UserModel();
                user.id = raw['id'];
                user.imagepath = raw['imagepath'];
                user.name = raw['name'];
                user.subname = raw['subname'];
                user.songpath = raw['songpath'];
                user.isFavourite = raw['isFavourite'];
                user.albumname = raw['albumname'];
                return user;
              })
              .where((user) => user.albumname == widget.albumName)
              .toList();
    });
  }

  void deleteSong(int index) async {
    bool confirmed = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Confirm Remove"),
            content: Text(
              "Do you really want to remove this song from the album?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Remove"),
              ),
            ],
          ),
    );
    if (confirmed) {
      await _userService.deleteUser(myList[index]);
      setState(() {
        myList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Song removed from the album"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "1970s hits",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Bottombar()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.greenAccent),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.builder(
          itemCount: myList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                if (widget.onPlay != null) {
                  widget.onPlay!(
                    myList
                        .map(
                          (user) => SongsModel(
                            id: user.id ?? 0,
                            name: user.name ?? '',
                            subname: user.subname ?? '',
                            imagepath: user.imagepath ?? '',
                            path: user.songpath ?? '',
                            album: user.albumname ?? '',
                          ),
                        )
                        .toList(),
                    index,
                  );
                }
              },
              leading: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: AssetImage(myList[index].imagepath.toString()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                myList[index].name.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(myList[index].subname.toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton(
                    child: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'remove') {
                        deleteSong(index);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'remove',
                            child: Center(child: Text("Remove")),
                          ),
                        ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyLibrary(isComeFromAlbum: true)),
          );
        },
        child: const Icon(Icons.add, color: Colors.greenAccent, size: 35),
      ),
    );
  }
}
