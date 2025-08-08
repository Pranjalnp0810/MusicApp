import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_album/Database/service.dart';
import 'package:music_album/Database/usermodel.dart';
import 'package:music_album/library.dart';

class MyFavouriteScreen extends StatefulWidget {
  const MyFavouriteScreen({super.key});

  @override
  State<MyFavouriteScreen> createState() => _MyFavouriteScreenState();
}

class _MyFavouriteScreenState extends State<MyFavouriteScreen> {
  List<UserModel> favouriteSongs = [];
  final Userservice _userservice = Userservice();

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    final songs = await _userservice.getFavouriteSongs();
    setState(() {
      favouriteSongs = songs;
    });
  }

  void removeFromFavourite(SongsModel song) {
    setState(() {
      favouriteSongs.remove(song);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Favourites"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
      ),
      body:
          favouriteSongs.isEmpty
              ? const Center(
                child: Text(
                  "No Favourite Song added!",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: favouriteSongs.length,
                itemBuilder: (context, index) {
                  final song = favouriteSongs[index];

                  return ListTile(
                    //  onTap: () => widget.onPlay(_favs, index),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        song.imagepath ?? "",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.name ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    ),
                  );
                },
              ),
    );
  }
}
