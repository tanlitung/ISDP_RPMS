class AppUser {

  final String uid;
  final String email;

  AppUser({
    required this.uid,
    required this.email });

}

class UserData {

  final String uid;
  final String name;
  final String position;
  final String age;
  final String gender;
  final Map data;
  final bool register;
  final int height;
  final int weight;
  final int bps;
  final int bpd;


  UserData({
    required this.uid,
    required this.name,
    required this.position,
    required this.age,
    required this.gender,
    required this.data,
    required this.register,
    required this.height,
    required this.weight,
    required this.bps,
    required this.bpd });

}