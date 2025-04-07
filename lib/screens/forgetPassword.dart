
import 'package:flutter/material.dart';
import '../Api/authApi.dart';
import 'OTPVerificationScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _sendResetCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    String email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = "Please enter a valid email.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await apiService.sendResetPasswordEmail(email);

      if (response['resetcode'] != null) {
        String receivedOtp = response['resetcode'];

        setState(() {
          _successMessage = "Reset code sent to your email!";
        });

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: email,  // ✅ Pass email
                otp: receivedOtp,  // ✅ Pass OTP
              ),
            ),
          );
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? "Failed to send reset code.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/background.jpg", fit: BoxFit.cover),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              Center(
                child: Text(
                  "ECO",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFB9DB7E),
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset("assets/logo.png", width: 150, height: 150),
                          const SizedBox(height: 10),
                          Text(
                            "Forgot Password?",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Enter your registered email to receive a reset code.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_errorMessage != null)
                            Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
                          if (_successMessage != null)
                            Text(_successMessage!, style: TextStyle(color: Colors.green, fontSize: 14)),
                          const SizedBox(height: 20),
                          _buildSendCodeButton(),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Back to Login", style: TextStyle(color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSendCodeButton() {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendResetCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0B6E4F), Color(0xFF80C783)]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "Send Reset Code",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
