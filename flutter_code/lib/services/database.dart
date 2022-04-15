import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/models/patient.dart';

class DatabaseService {

  final String? uid;
  DatabaseService({ this.uid });

  // Collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('user');

  Future updateUserData(String uid, String name, String position, String age, String gender, Map data, bool register, int height, int weight, int bps, int bpd) async {
    return await userCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'position': position,
      'age': age,
      'gender': gender,
      'data': data,
      'register': register,
      'height': height,
      'weight': weight,
      'bps': bps,
      'bpd': bpd,
    });
  }

  Future updateSingleUserData(String key, var value) async {
    return await userCollection.doc(uid).update({
      key: value,
    });
  }

  // User data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid!,
      name: snapshot.get('name'),
      position: snapshot.get('position'),
      age: snapshot.get('age'),
      gender: snapshot.get('gender'),
      data: snapshot.get('data'),
      register: snapshot.get('register'),
      height: snapshot.get('height'),
      weight: snapshot.get('weight'),
      bps: snapshot.get('bps'),
      bpd: snapshot.get('bpd'),
    );
  }

  // Get patient list from snapshot
  List<UserData> _userListFromSnapShot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
        uid: doc.get('uid'),
        name: doc.get('name'),
        position: doc.get('position'),
        age: doc.get('age'),
        gender: doc.get('gender'),
        data: doc.get('data'),
        register: doc.get('register'),
        height: doc.get('height'),
        weight: doc.get('weight'),
        bps: doc.get('bps'),
        bpd: doc.get('bpd'),
      );
    }).toList();
  }

  // Get user data
  Future getUserData (String data) async {

    var document = await userCollection.doc(uid).get();
    return document.get(data);
  }

  // Get user stream
  Stream<List<UserData>> get users {
    return userCollection.snapshots()
    .map(_userListFromSnapShot);
  }

  // Get user docs stream
  Stream<UserData> get userData {
    // print(userCollection.doc(uid));
    return userCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }
}