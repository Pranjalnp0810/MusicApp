class UserModel {
  int? id;
  String? imagepath;
  String? name;
  String? subname;
  String? songpath;
  String? isFavourite;
  String? albumname;
  bool isPlay;

  UserModel({
    this.id,
    this.imagepath,
    this.name,
    this.subname,
    this.songpath,
    this.isFavourite,
    this.albumname,
    this.isPlay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "imagepath": imagepath,
      "name": name,
      "subname": subname,
      "songpath": songpath,
      "isFavourite": isFavourite,
      "albumname": albumname,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      imagepath: map["imagepath"],
      name: map["name"],
      subname: map["subname"],
      songpath: map["songpath"],
      isFavourite: map["isFavourite"],
      albumname: map["albumname"],
    );
  }
}
