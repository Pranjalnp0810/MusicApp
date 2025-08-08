import 'package:music_album/Database/repository.dart';
import 'package:music_album/Database/usermodel.dart';

class Userservice {
  late Repository repository;

  Userservice() {
    repository = Repository();
  }

  Future<int> saveUser(UserModel? userModel) async {
    return await repository.insertData("myTable", userModel!.toMap());
  }

  Future<List<Map<String, dynamic>>> displayUser() async {
    return await repository.getData("myTable");
  }

  Future<int> updateUser(UserModel? userModel) async {
    return await repository.updateData("myTable", userModel!.toMap());
  }

  Future<int> deleteUser(UserModel? userModel) async {
    return await repository.deleteData("myTable", userModel!.toMap());
  }

  // Future<List<Map<String, dynamic>>> getFavouriteSongs() async {
  //   return await repository.getDataByCondition(
  //     "myTable",
  //     "isFavourite = 'true'",
  //   );
  // }

  Future<List<UserModel>> getFavouriteSongs() async {
    final data = await repository.getDataByCondition(
      "myTable",
      "isFavourite = 'true'",
    );
    return data
        .map(
          (e) => UserModel(
            id: e['id'],
            imagepath: e['imagepath'],
            name: e['name'],
            subname: e['subname'],
            songpath: e['songpath'],
            isFavourite: e['isFavourite'],
            albumname: e['albumname'],
          ),
        )
        .toList();
  }

  Future<int> updateFavouriteStatus(int id, bool isFavourite) async {
    return await repository.updateRaw(
      "UPDATE myTable SET isFavourite = ? where id = ?",
      [isFavourite.toString(), id],
    );
  }

  Future<Map<String, dynamic>?> getSongById(int id) async {
    List<Map<String, dynamic>> result = await repository.getDataByCondition(
      "myTable",
      "id = $id",
    );

    return result.isNotEmpty ? result.first : null;
  }
}
