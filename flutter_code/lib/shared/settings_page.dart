import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/services/database.dart';
import 'package:isdp/shared/loading.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String name = '';
  String age = '';
  String gender = '';
  var height = 0;
  var weight = 0;
  var bpd = 0;
  var bps = 0;
  String error = '';

  Widget getGenderCard(bool selected, IconData icon, String name) {
    return Card(
        color: selected ? Color(0xFF3B4257) : Colors.white,
        child: Container(
          height: 80,
          width: 80,
          alignment: Alignment.center,
          margin: new EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: selected ? Colors.white : Colors.grey,
                size: 40,
              ),
              SizedBox(height: 5.0),
              Text(
                name,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey),
              )
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData>(context);

    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services,
                  color: Colors.grey[700],
                  size: 40.0,
                ),
                // SizedBox(height: 10.0),
                // Text(
                //   'ISDP G3',
                //   style: TextStyle(
                //       fontSize: 40.0,
                //       color: Colors.grey[700]
                //   ),
                // ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                          thickness: 2.0,
                        )
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "Settings",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey[700]
                        ),
                      ),
                    ),

                    Expanded(
                        child: Divider(
                          thickness: 2.0,
                        )
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: userData.name == '' ? null : userData.name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  onChanged: (val) {
                    print(name);
                    setState(() => name = val);
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  initialValue: userData.age == '' ? null : userData.age,
                  decoration: InputDecoration(
                    labelText: 'Age',
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter yor age' : null,
                  onChanged: (val) {
                    setState(() => age = val);
                  },
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        initialValue: userData.height == 0 ? null : userData.height.toString(),
                        decoration: InputDecoration(
                          labelText: 'Height (cm)',
                        ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Invalid height';
                          } else {
                            if (int.parse(val) < 10) {
                              return 'Invalid height';
                            } else {
                              return null;
                            }
                          }
                        },
                        onChanged: (val) {
                          print('height: ${height}');
                          setState(() => height = int.parse(val));
                        },
                      ),
                    ),
                    SizedBox(width: 30.0),
                    Flexible(
                      child: TextFormField(
                        initialValue: userData.weight == 0 ? null : userData.weight.toString(),
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Invalid weight';
                          } else {
                            if (int.parse(val) < 10) {
                              return 'Invalid weight';
                            } else {
                              return null;
                            }
                          }
                        },
                        onChanged: (val) {
                          print('weight: ${weight}');
                          setState(() => weight = int.parse(val));
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: TextFormField(
                        initialValue: userData.bps == 0 ? null : userData.bps.toString(),
                        decoration: InputDecoration(
                          labelText: 'BP (mmHg)',
                        ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Invalid blood pressure';
                          } else {
                            if (int.parse(val) < 10) {
                              return 'Invalid blood pressure';
                            } else {
                              return null;
                            }
                          }
                        },
                        onChanged: (val) {
                          print('bps: ${bps}');
                          setState(() => bps = int.parse(val));
                        },
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Text(
                      '/',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Flexible(
                      child: TextFormField(
                        initialValue: userData.bpd == 0 ? null : userData.bpd.toString(),
                        decoration: InputDecoration(
                          labelText: '',
                        ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Invalid blood pressure';
                          } else {
                            if (int.parse(val) < 10) {
                              return 'Invalid blood pressure';
                            } else {
                              return null;
                            }
                          }
                        },
                        onChanged: (val) {
                          print('bpd: ${bpd}');
                          if (val == '') {
                            setState(() => bpd = 0);
                          }
                          else {
                            setState(() => bpd = int.parse(val));
                          }
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      child: getGenderCard(userData.gender == 'male' ? true
                          : false, Icons.male, 'Male'),
                      onTap: () async {
                        await DatabaseService(uid: userData.uid).updateSingleUserData('gender', 'male');
                      },
                    ),
                    InkWell(
                        child: getGenderCard(userData.gender == 'female' ? true
                            : false, Icons.female, 'Female'),
                        onTap: () async {
                          await DatabaseService(uid: userData.uid).updateSingleUserData('gender', 'female');
                        }
                    ),
                  ],
                ),
                SizedBox(height: 25.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 100.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      )
                  ),
                  child: Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      print('Error in form： ${error}');
                      setState(() {
                        loading = true;
                        gender = gender == '' ? userData.gender : gender;
                        name = name == '' ? userData.name : name;
                        age = age == '' ? userData.age : age;
                        height = height == 0 ? userData.height: height;
                        weight = weight == 0 ? userData.weight : weight;
                        bps = bps == 0 ? userData.bps : bps;
                        bpd = bpd == 0 ? userData.bpd : bpd;
                      });
                      if ((gender == '') | (name == '') | (age == '') | (height == 0) | (weight == 0) | (bps == 0) | (bpd == 0)) {
                        setState(() {
                          error = 'Please complete the form';
                        });
                      } else {
                        // Update user data in database
                        await DatabaseService(uid: userData.uid).updateSingleUserData('name', name);
                        await DatabaseService(uid: userData.uid).updateSingleUserData('age', age);
                        await DatabaseService(uid: userData.uid).updateSingleUserData('height', height);
                        await DatabaseService(uid: userData.uid).updateSingleUserData('weight', weight);
                        await DatabaseService(uid: userData.uid).updateSingleUserData('bps', bps);
                        await DatabaseService(uid: userData.uid).updateSingleUserData('bpd', bpd);
                        await DatabaseService(uid: userData.uid).updateSingleUserData('register', true);
                      }
                    }

                    else {
                      setState(() {
                        error = 'Form Imcomplete!';
                      });
                    }

                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}


