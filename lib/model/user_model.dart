class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  List? posts = [];
  List? saves = [];

  UserModel(
      {this.uid,
      this.email,
      this.firstName,
      this.secondName,
      this.posts,
      this.saves});

  //get data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        firstName: map['firstName'],
        secondName: map['secondName'],
        posts: map['posts'],
        saves: map['saves']);
  }

  //send data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'posts': posts,
      'saves': saves
    };
  }
}
