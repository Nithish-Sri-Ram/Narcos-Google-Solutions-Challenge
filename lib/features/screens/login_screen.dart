import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/common/sign_in_button.dart';
import 'package:drug_discovery/core/constants/constants.dart';
import 'package:drug_discovery/features/controller/auth_controller.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
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
              child: Text(
                'Skip',
                style: TextStyle(fontWeight: FontWeight.bold,color: Pallete.blueColor),
              ),
            )
          ],
        ),
        body: isLoading?const Loader(): Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Cure Seeking Minds',
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
