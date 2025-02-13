import 'package:drug_discovery/core/common/sign_in_button.dart';
import 'package:drug_discovery/core/constants/constants.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              Pallete.darkModeAppTheme.primaryColorDark, // Ensure proper color
          flexibleSpace: Center(
            child: Image.asset(
              Constants.logoPath,
              height: 100,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Skip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Dive into anything',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                Constants.loginEmotePath,
                height: 400,
              ),
            ),
            const SizedBox(height: 20),
            const SignInButton(),
          ],
        ),
      ),
    );
  }
}
