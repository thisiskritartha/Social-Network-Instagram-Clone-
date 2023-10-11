import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_network/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String? username;

  submit() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form!.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  bool containsNumericDigit(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context,
            title: "Set up your Profile", removeBackButton: true),
        body: ListView(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Create a username',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: TextFormField(
                      validator: (val) {
                        if (val!.trim().length < 3 || val.isEmpty) {
                          return 'Username too short';
                        } else if (val!.trim().length > 15) {
                          return 'Username too long.';
                        } else if (!containsNumericDigit(val)) {
                          return 'Username must contain at least one numeric digit';
                        }
                        return null;
                      },
                      onSaved: (val) => username = val!,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        labelStyle: TextStyle(fontSize: 16.0),
                        hintText: "Must be atleast 3 characters.",
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
