import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isdp/services/auth.dart';
import 'package:isdp/shared/loading.dart';
import 'package:isdp/shared/settings_page.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ required this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // Text field state
  String name = '';
  String email = '';
  String password = '';
  String doctor = '';
  List<String> _doctors = ['Dr. Norashikin'];
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(20.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
      ),
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
              SizedBox(height: 10.0),
              Text(
                'ISDP G3',
                style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.grey[700]
                ),
              ),
              SizedBox(height: 30.0),
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
                      "Sign Up",
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
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.mail),
                  labelText: 'Email',
                ),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.vpn_key),
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    )
                ),
                child: Text('Sign Up'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.register(email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Sign up failed! Please try again';
                        loading = false;
                      });
                    }
                    if (result == 0) {
                      setState(() {
                        error = 'Email is taken!';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 30.0),
              RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have account? ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              widget.toggleView();
                            }
                      ),
                    ]
                ),
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
