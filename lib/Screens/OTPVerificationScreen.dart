import 'package:flutter/material.dart';
import '../Api/authApi.dart';
import 'resetPasswordScreen.dart'; // Import the reset password screen

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String otp;

  const OTPVerificationScreen({super.key, required this.email, required this.otp});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final ApiService apiService = ApiService();
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOTP() {
    String enteredOTP = _otpControllers.map((controller) => controller.text).join();

    if (enteredOTP.length < 4) {
      setState(() {
        _errorMessage = "Please enter all 4 digits of the OTP.";
      });
      return;
    }

    if (enteredOTP == widget.otp) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            code: enteredOTP, // ✅ Passing OTP as the code parameter
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid OTP. Please try again.";
      });
    }
  }

  Widget _buildOTPInputField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index].unfocus();
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            }
          } else if (index > 0) {
            _focusNodes[index].unfocus();
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
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
                            "Verify OTP",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Enter the 4-digit OTP sent to ${widget.email}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) => _buildOTPInputField(index)),
                          ),
                          const SizedBox(height: 20),
                          if (_errorMessage != null)
                            Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
                          const SizedBox(height: 20),
                          _buildVerifyButton(),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Resend OTP", style: TextStyle(color: Colors.blueAccent)),
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

  Widget _buildVerifyButton() {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
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
              "Verify OTP",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
