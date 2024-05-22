import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/loading_screen.dart';
import 'custom_toast.dart';
// import '../functions/login.dart';
import '../providers/auth.dart';

enum AuthMode { Signup, Login }

bool forgotPassword = false;

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'confirmPassword': '',
    'name': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  bool is_visible = true;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setVisibility() {
    setState(() {
      is_visible = !is_visible;
    });
  }

  void isVisible() {
    setState(() {
      obscure = !obscure;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    // Show dialog only when _isLoading is true

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_authMode == AuthMode.Login) {
        await authProvider.signInWithEmailAndPassword(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await authProvider.registerWithEmailAndPassword(
          _authData['email']!,
          _authData['password']!,
          _authData['name']!,
        );
      }

      // Authentication successful, handle navigation or UI changes here
    } catch (error) {
      // Handle authentication errors (e.g., display error message)
    } finally {
      // if (_isLoading) {
      //   Navigator.of(context).pop(); // Close the dialog
      // }
      setState(() {
        _isLoading = false;
      });
    }
    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Stack(children: [
      Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            height: _authMode == AuthMode.Signup ? 400 : 300,
            constraints: BoxConstraints(
              minHeight: _authMode == AuthMode.Signup ? 400 : 300,
            ),
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid email!';
                        }
                      },
                      onSaved: (value) {
                        _authData['email'] = value!;
                      },
                    ),
                    TextFormField(
                      enabled: _authMode == AuthMode.Login ||
                          _authMode == AuthMode.Signup,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: setVisibility,
                          icon: Icon(is_visible
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                      obscureText: is_visible,
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return 'Password is too short!';
                        }
                      },
                      onSaved: (value) {
                        _authData['password'] = value!;
                      },
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: _authMode == AuthMode.Signup
                          ? Column(
                              children: [
                                TextFormField(
                                  enabled: _authMode == AuthMode.Signup,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    suffixIcon: IconButton(
                                      onPressed: isVisible,
                                      icon: Icon(obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                    ),
                                  ),
                                  obscureText: obscure,
                                  controller: _confirmPasswordController,
                                  validator: _authMode == AuthMode.Signup
                                      ? (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match!';
                                          }
                                        }
                                      : null,
                                  onSaved: (value) {
                                    _authData['confirmPassword'] = value!;
                                  },
                                ),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Name'),
                                  controller: _nameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your name!';
                                    }
                                  },
                                  onSaved: (value) {
                                    _authData['name'] = value!;
                                  },
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password"),
                    ),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else if (!forgotPassword)
                      ElevatedButton(
                        child: Text(
                          _authMode == AuthMode.Login ? "Login" : "Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          //print("here");
                          _submit(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                          textStyle: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .labelLarge!
                                .color,
                          ),
                        ),
                      ),
                    if (forgotPassword)
                      ElevatedButton(
                        child: Text("Reset Password"),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                          textStyle: TextStyle(
                              //color: Theme.of(context).primaryTextTheme.button.color,
                              ),
                        ),
                      ),
                    TextButton(
                      onPressed: _switchAuthMode,
                      child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                        //style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      if (_isLoading) Center(child: LoadingScreen())
    ]);
  }
}
