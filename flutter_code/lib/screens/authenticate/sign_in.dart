import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isdp/services/auth.dart';
import 'package:isdp/shared/loading.dart';

class SignIn extends StatefulWidget {
  // const SignIn({Key? key}) : super(key: key);

  final Function toggleView;
  SignIn({ required this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // Text field state
  String email = '';
  String password = '';
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
                      "Sign In",
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
                child: Text('Sign In'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.signIn(email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Incorrect credentials!';
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
                      text: 'Don\'t have account? ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Sign Up',
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
