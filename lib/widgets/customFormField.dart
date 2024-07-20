import 'package:flutter/material.dart';

class MyFormField extends StatelessWidget {
  MyFormField(
      {super.key,
      required this.obsecureText,
      required this.hintText,
      required this.validatorExp,
      required this.onSaved});
  final bool obsecureText;
  final String hintText;
  final RegExp validatorExp;
  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obsecureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      validator: (value) {
        return (value != null && validatorExp.hasMatch(value))
            ? null
            : "Enter a valid ${hintText.toLowerCase()}";
      },
      onSaved: onSaved,
    );
  }
}
