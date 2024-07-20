import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/consts.dart';
import 'package:pchat_app/models/user_profile.dart';
import 'package:pchat_app/services/alert_service.dart';
import 'package:pchat_app/services/auth_services.dart';
import 'package:pchat_app/services/database_service.dart';
import 'package:pchat_app/services/media_service.dart';
import 'package:pchat_app/services/navigation_service.dart';
import 'package:pchat_app/services/storage_services.dart';
import 'package:pchat_app/widgets/customFormField.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  File? selectedImage;
  final GetIt _getIt = GetIt.instance;
  String? email, password, name;
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  // services
  late MediaService _mediaService;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  // Business Logic
  void registerUser() async {
    try {
      if ((formKey.currentState?.validate() ?? false) &&
          selectedImage != null) {
        formKey.currentState?.save();

        setState(() {
          isLoading = true;
        });

        bool response = await _authService.signUp(email!, password!);
        if (response) {
          String? pfpUrl = await _storageService.uploadUserProfilePicture(
              file: selectedImage!, uid: _authService.user!.uid);
          if (pfpUrl != null) {
            await _databaseService.createUserProfile(
                userProfile: UserProfile(
                    uid: _authService.user!.uid, name: name, pfpURL: pfpUrl));
            _alertService.showToast(
                message: "Account Created Successfully", icon: Icons.check);
            _navigationService.goBack();
            _navigationService.pushReplacementNamed("/home");
          } else {
            throw Exception("Unable to Upload the profile picture");
          }
        } else {
          throw Exception("Unable to Register the user");
        }
      }
    } catch (e) {
      log(e.toString());
      _alertService.showToast(
          message: "Failed to Register! Please, try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              children: !isLoading
                  ? [_headerText(), _signUpForm()]
                  : [Center(child: CircularProgressIndicator())],
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
            "Lets, get going",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            "Register an account using the form below",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget _signUpForm() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
          key: formKey,
          child: Column(
            children: [
              _pfpSelectionField(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              MyFormField(
                  obsecureText: false,
                  hintText: "Name",
                  validatorExp: NAME_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      name = value;
                    });
                  }),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              MyFormField(
                  obsecureText: false,
                  hintText: "Email",
                  validatorExp: EMAIL_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      email = value;
                    });
                  }),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              MyFormField(
                  obsecureText: true,
                  hintText: "Password",
                  validatorExp: PASSWORD_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      password = value;
                    });
                  }),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              _signUpButton(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.01,
              ),
              _LogInLink(),
            ],
          )),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getFileFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP),
      ),
    );
  }

  Widget _signUpButton() {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(34.0),
      ),
      child: InkWell(
        onTap: registerUser,
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: const Center(
            child: Text(
              'Sign Up',
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

  Widget _LogInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text('Not a member? '),
        GestureDetector(
          onTap: () {
            _navigationService.goBack();
          },
          child: const Text(
            "Log In",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
