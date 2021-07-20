import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';
import '../models/authEnum.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  DecorationImage _buildDecorationImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.6),
        BlendMode.dstATop,
      ),
      image: AssetImage('assets/background.jpg'),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-Mail Address',
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      // ignore: missing_return
      validator: (String? value) {
        if (value == null ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Enter a valid email address';
        }
      },
      onSaved: (String? value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      controller: _passwordTextController,
      // ignore: missing_return
      validator: (String? value) {
        if (value == null || value.length < 5) {
          return 'password is incorrect';
        }
      },
      onSaved: (String? value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
          // ignore: missing_return
          validator: (String? value) {
            if (_passwordTextController.text != value &&
                _authMode == AuthMode.Signup) {
              return 'password does not match';
            }
          },
        ),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text(
        'Accept Terms',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState!.validate() || !_formData['acceptTerms']) {
      return;
    }
    _formKey.currentState!.save();

    Map<String, dynamic> successInformation = await authenticate(
        _formData['email'], _formData['password'], _authMode);
    if (successInformation['success']) {
      print(successInformation['message']);
      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('An error has occured'),
                content: Text(successInformation['message']),
                actions: [
                  TextButton(
                    child: Text('Okay'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: Text('START PAGE'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildDecorationImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEmailTextField(),
                    SizedBox(height: 10.0),
                    _buildPasswordTextField(),
                    SizedBox(height: 10.0),
                    _buildPasswordConfirmTextField(),
                    _buildAcceptSwitch(),
                    SizedBox(height: 10.0),
                    TextButton(
                      child: Text(
                          'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                      onPressed: () {
                        if (_authMode == AuthMode.Login) {
                          setState(() {
                            // ignore: unnecessary_statements
                            _authMode = AuthMode.Signup;
                          });
                          _controller.forward();
                        } else if (_authMode == AuthMode.Signup) {
                          setState(() {
                            // ignore: unnecessary_statements
                            _authMode = AuthMode.Login;
                          });
                          _controller.reverse();
                        }
                      },
                    ),
                    SizedBox(height: 10.0),
                    ScopedModelDescendant<MainModel>(builder:
                        (BuildContext context, Widget? child, MainModel model) {
                      return model.isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              child: Text(_authMode == AuthMode.Login
                                  ? 'LOGIN'
                                  : 'SIGNUP'),
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).accentColor,
                                onPrimary: Colors.white,
                              ),
                              onPressed: () => _submitForm(model.authenticate),
                            );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
