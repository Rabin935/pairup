import 'package:flutter/material.dart';
import 'package:pairup/screens/verification_code_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 0,
                top: 100,
                right: 0,
                bottom: 0,
              ),
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: [
                    TextSpan(text: "What's your email?"),
                    TextSpan(
                      text:
                          "\nWe'll send you a verification code for you to confirm.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 99, 99, 99),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),

            Padding(
              padding: const EdgeInsets.only(
                left: 0,
                top: 100,
                right: 0,
                bottom: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.left,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Your email address won't be shown publicly.",
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationCodeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Send code",
                    style: TextStyle(
                      fontSize: 22,
                      // fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 92, 92, 92),
                    ),
                  ),
                ),
              ),
            ),

            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 60)),
            // const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
