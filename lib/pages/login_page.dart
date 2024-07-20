import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/consts.dart';
import 'package:pchat_app/services/alert_service.dart';
import 'package:pchat_app/services/auth_services.dart';
import 'package:pchat_app/services/navigation_service.dart';
import 'package:pchat_app/widgets/customFormField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey();
  String? email, password;
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_headerText(), _loginForm(), _signUpLink()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Welcome Back",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            "Hello Again, You Have been missed",
            style: TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            MyFormField(
              obsecureText: false,
              hintText: 'Email',
              validatorExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.03,
            ),
            MyFormField(
              obsecureText: true,
              hintText: 'Password',
              validatorExp: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.03,
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(34.0),
      ),
      child: InkWell(
        onTap: () async {
          if (formKey.currentState?.validate() ?? false) {
            formKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            log(result.toString());
            if (result) {
              _navigationService.pushReplacementNamed("/home");
            } else {
              _alertService.showToast(
                  message: "Login Failed, Please Try Again!");
            }
          } else {
            _alertService.showToast(message: "Please Enter valid credentials");
          }
        },
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: const Center(
            child: Text(
              'Log In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text('Not a member? '),
        GestureDetector(
          onTap: () {
            _navigationService.pushNamed("/register");
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
